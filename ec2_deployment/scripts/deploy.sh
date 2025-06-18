#!/bin/bash
set -e

# Deploy script for Java application
# Usage: ./deploy.sh [stage] [instance_ip]

STAGE=${1:-"dev"}
INSTANCE_IP=${2:-""}

if [ -z "$INSTANCE_IP" ]; then
    echo "Error: Instance IP is required"
    echo "Usage: ./deploy.sh [stage] [instance_ip]"
    exit 1
fi

echo "Starting deployment for stage: $STAGE"
echo "Target instance: $INSTANCE_IP"

# Check if SSH key exists
if [ ! -f "key_pair/id_rsa" ]; then
    echo "Error: SSH private key not found at key_pair/id_rsa"
    exit 1
fi

# Set permissions for SSH key
chmod 600 key_pair/id_rsa

# Wait for SSH to be available
echo "Waiting for SSH connection..."
for i in {1..10}; do
    if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i key_pair/id_rsa ubuntu@$INSTANCE_IP 'echo SSH ready'; then
        echo "SSH connection established"
        break
    fi
    echo "Attempt $i: SSH not ready yet, waiting..."
    sleep 10
done

# Upload and execute setup script
echo "Uploading setup script..."
scp -o StrictHostKeyChecking=no -i key_pair/id_rsa scripts/setup.sh ubuntu@$INSTANCE_IP:/tmp/setup.sh

echo "Executing setup script..."
ssh -o StrictHostKeyChecking=no -i key_pair/id_rsa ubuntu@$INSTANCE_IP "chmod +x /tmp/setup.sh && /tmp/setup.sh 21 https://github.com/techeazy-consulting/techeazy-devops 20 ${STAGE}-config-bucket"

# Health check
echo "Performing health check..."
for i in {1..15}; do
    if curl -s --max-time 10 http://$INSTANCE_IP:8080 > /dev/null; then
        echo "Deployment successful! Application is running on http://$INSTANCE_IP:8080"
        exit 0
    fi
    echo "Health check attempt $i failed, retrying..."
    sleep 10
done

echo "Health check failed after 15 attempts"
exit 1
