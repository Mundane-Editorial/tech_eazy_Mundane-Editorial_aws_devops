#!/bin/bash
set -e

java_version=$1
repo_url=$2
shutdown_threshold=$3
bucket_name=$4

# System update and prerequisites
sudo apt update -y
sudo apt install -y openjdk-${java_version}-jdk git unzip

# Install AWS CLI if not present
if ! command -v aws &> /dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
fi

# Clone and build application
git clone ${repo_url}
REPO_NAME=$(basename -s .git ${repo_url})
cd $REPO_NAME
chmod +x mvnw
./mvnw clean package

# Run application
JAR_FILE=$(find target -type f -name "*.jar" | head -n 1)
nohup java -jar $JAR_FILE --server.port=8080 > app.log 2>&1 &

# Create and upload app logs
sudo mkdir -p /app/logs
sudo mv app.log /app/logs/app.log
aws s3 cp /app/logs/ s3://${bucket_name}/app/logs/ --recursive

# Setup shutdown service to upload EC2 logs
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
sudo shutdown -h +${shutdown_threshold}