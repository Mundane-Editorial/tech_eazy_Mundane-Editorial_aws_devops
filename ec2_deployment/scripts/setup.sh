#!/bin/bash
set -e

java_version=$1
repo_url=$2
shutdown_threshold=$3
bucket_name=$4

echo "Starting setup with Java version: $java_version"
echo "Repository URL: $repo_url"
echo "Shutdown threshold: $shutdown_threshold"
echo "Bucket name: $bucket_name"

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

echo "Java version installed:"
java -version

# Install AWS CLI
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

# Clone and build application
echo "Cloning repository: $repo_url"
git clone ${repo_url}
REPO_NAME=$(basename -s .git ${repo_url})
echo "Repository name: $REPO_NAME"
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

# Run application
echo "Starting application..."
JAR_FILE=$(find target -type f -name "*.jar" | head -n 1)
echo "JAR file found: $JAR_FILE"

if [ -n "$JAR_FILE" ]; then
    nohup java -jar $JAR_FILE --server.port=8080 > app.log 2>&1 &
    echo "Application started with PID: $!"
else
    echo "No JAR file found in target directory!"
    exit 1
fi

# Wait a moment for application to start
sleep 10

# Create and upload app logs
echo "Setting up logging..."
sudo mkdir -p /app/logs
sudo mv app.log /app/logs/app.log 2>/dev/null || echo "app.log not found, continuing..."

# Upload logs to S3
echo "Uploading logs to S3..."
aws s3 cp /app/logs/ s3://${bucket_name}/app/logs/ --recursive || echo "Failed to upload logs to S3"

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
ExecStop=/usr/bin/aws s3 cp /var/log/cloud-init.log s3://${bucket_name}/ec2-logs/
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