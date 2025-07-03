#!/bin/bash
set -e

java_version=$1
repo_url=$2
shutdown_threshold=$3
bucket_name=$4
stage=$5

echo "Starting setup for stage: $stage"
echo "Java version: $java_version"
echo "Repository: $repo_url"
echo "Shutdown threshold: $shutdown_threshold minutes"

# System update and prerequisites
echo "Updating system packages..."
sudo apt update -y

# Install Java based on version
echo "Installing Java $java_version..."
if [ "$java_version" = "21" ]; then
    sudo apt install -y software-properties-common
    sudo add-apt-repository ppa:openjdk-r/ppa -y
    sudo apt update -y
    sudo apt install -y openjdk-21-jdk
elif [ "$java_version" = "19" ]; then
    sudo apt install -y openjdk-19-jdk
elif [ "$java_version" = "17" ]; then
    sudo apt install -y openjdk-17-jdk
elif [ "$java_version" = "11" ]; then
    sudo apt install -y openjdk-11-jdk
else
    echo "Installing default Java version..."
    sudo apt install -y default-jdk
fi

# Install jq for JSON parsing
echo "Installing jq for JSON parsing..."
sudo apt install -y jq

# Install AWS CLI if not present
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

# Load configuration from JSON file
echo "Loading configuration from app_config.json..."
if [ -f "/home/$USER/app_config.json" ]; then
    echo "Configuration file found, parsing..."
    
    # Read config values
    ENVIRONMENT=$(jq -r '.environment' /home/$USER/app_config.json)
    DEBUG_MODE=$(jq -r '.debug' /home/$USER/app_config.json)
    LOG_LEVEL=$(jq -r '.logging.level' /home/$USER/app_config.json)
    S3_BUCKET=$(jq -r '.logging.s3_bucket' /home/$USER/app_config.json)
    S3_PATH=$(jq -r '.logging.s3_path' /home/$USER/app_config.json)
    SERVER_PORT=$(jq -r '.server.port' /home/$USER/app_config.json)
    
    echo "=== Configuration Loaded ==="
    echo "Environment: $ENVIRONMENT"
    echo "Debug mode: $DEBUG_MODE"
    echo "Log level: $LOG_LEVEL"
    echo "S3 bucket: $S3_BUCKET"
    echo "S3 path: $S3_PATH"
    echo "Server port: $SERVER_PORT"
    echo "=========================="
    
    # Export environment variables
    export APP_ENVIRONMENT=$ENVIRONMENT
    export APP_DEBUG=$DEBUG_MODE
    export APP_LOG_LEVEL=$LOG_LEVEL
    export APP_S3_BUCKET=$S3_BUCKET
    export APP_S3_PATH=$S3_PATH
    export APP_SERVER_PORT=$SERVER_PORT
    
else
    echo "Warning: app_config.json not found, using default values"
    ENVIRONMENT="unknown"
    DEBUG_MODE="false"
    LOG_LEVEL="INFO"
    S3_BUCKET=$bucket_name
    S3_PATH="logs/$stage/"
    SERVER_PORT=8080
fi

# Clone and build application
echo "Cloning repository: $repo_url"
git clone ${repo_url}
REPO_NAME=$(basename -s .git ${repo_url})
cd $REPO_NAME

# Check if Maven wrapper exists
if [ -f "mvnw" ]; then
    echo "Using Maven wrapper..."
    chmod +x mvnw
    ./mvnw clean package
else
    echo "Maven wrapper not found, installing Maven..."
    sudo apt install -y maven
    mvn clean package
fi

# Run application with config
echo "Starting application with configuration..."
JAR_FILE=$(find target -type f -name "*.jar" | head -n 1)

if [ -n "$JAR_FILE" ]; then
    # Start application with environment variables and config
    nohup java -jar $JAR_FILE \
        --server.port=$SERVER_PORT \
        --spring.profiles.active=$ENVIRONMENT \
        --logging.level.root=$LOG_LEVEL \
        --app.debug=$DEBUG_MODE \
        --app.environment=$ENVIRONMENT \
        > app.log 2>&1 &
    
    echo "Application started with PID: $!"
    echo "Application configuration:"
    echo "  Port: $SERVER_PORT"
    echo "  Environment: $ENVIRONMENT"
    echo "  Debug: $DEBUG_MODE"
    echo "  Log level: $LOG_LEVEL"
else
    echo "No JAR file found in target directory!"
    exit 1
fi

# Wait for application to start
sleep 10

# Create and upload app logs
echo "Setting up logging..."
sudo mkdir -p /app/logs
sudo mv app.log /app/logs/app.log 2>/dev/null || echo "app.log not found, continuing..."

# Install and configure CloudWatch Agent
CWA_CONFIG_SRC="/home/$USER/app_config/cloudwatch-agent-config.json"
CWA_CONFIG_DST="/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-agent-config.json"

if [ -f "$CWA_CONFIG_SRC" ]; then
    echo "Installing CloudWatch Agent..."
    sudo wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i amazon-cloudwatch-agent.deb
    echo "Copying CloudWatch Agent config..."
    sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
    sudo cp "$CWA_CONFIG_SRC" "$CWA_CONFIG_DST"
    echo "Starting CloudWatch Agent..."
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config \
      -m ec2 \
      -c file:$CWA_CONFIG_DST \
      -s
else
    echo "CloudWatch Agent config not found, skipping CloudWatch Agent setup."
fi

# Upload logs to stage-specific S3 folder
echo "Uploading logs to S3 for stage $stage..."
aws s3 cp /app/logs/ s3://${S3_BUCKET}/${S3_PATH} --recursive || echo "Failed to upload logs to S3"

# Setup shutdown service to upload EC2 logs
echo "Setting up shutdown service..."
cat << EOF | sudo tee /etc/systemd/system/upload-ec2-logs.service
[Unit]
Description=Upload EC2 logs to S3 on shutdown
DefaultDependencies=no
Before=shutdown.target

[Service]
Type=oneshot
ExecStart=/bin/true
ExecStop=/usr/bin/aws s3 cp /var/log/cloud-init.log s3://${S3_BUCKET}/ec2-logs/
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable upload-ec2-logs.service

# Schedule shutdown
echo "Scheduling shutdown in $shutdown_threshold minutes..."
sudo shutdown -h +${shutdown_threshold}

echo "Setup completed successfully!"
echo "Application is running with $ENVIRONMENT configuration"
echo "Access your application at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):$SERVER_PORT"