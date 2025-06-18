#!/bin/bash

echo "🔍 Validating DevOps Project Setup..."
echo "======================================"

# Check if we're in the right directory
if [ ! -f "main.tf" ]; then
    echo "❌ Error: Please run this script from the ec2_deployment directory"
    exit 1
fi

# Check Terraform installation
if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform is not installed"
    echo "Please install Terraform from https://www.terraform.io/downloads"
    exit 1
else
    echo "✅ Terraform is installed: $(terraform version | head -n1)"
fi

# Check AWS CLI installation
if ! command -v aws &> /dev/null; then
    echo "⚠️  Warning: AWS CLI is not installed (optional for local validation)"
else
    echo "✅ AWS CLI is installed: $(aws --version)"
fi

# Check SSH key pair
if [ ! -f "key_pair/id_rsa.pub" ]; then
    echo "❌ Error: SSH public key not found at key_pair/id_rsa.pub"
    echo "Please generate SSH keys: ssh-keygen -t rsa -b 2048 -f key_pair/id_rsa -N ''"
    exit 1
else
    echo "✅ SSH public key found"
fi

# Check config files
if [ ! -f "config/dev_config.tfvars" ]; then
    echo "❌ Error: Development config file not found"
    exit 1
else
    echo "✅ Development config file found"
fi

if [ ! -f "config/prod_config.tfvars" ]; then
    echo "❌ Error: Production config file not found"
    exit 1
else
    echo "✅ Production config file found"
fi

# Check scripts
if [ ! -f "scripts/setup.sh" ]; then
    echo "❌ Error: Setup script not found"
    exit 1
else
    echo "✅ Setup script found"
fi

if [ ! -f "scripts/deploy.sh" ]; then
    echo "❌ Error: Deploy script not found"
    exit 1
else
    echo "✅ Deploy script found"
fi

# Check if scripts are executable
if [ ! -x "scripts/setup.sh" ]; then
    echo "⚠️  Warning: Setup script is not executable, fixing..."
    chmod +x scripts/setup.sh
fi

if [ ! -x "scripts/deploy.sh" ]; then
    echo "⚠️  Warning: Deploy script is not executable, fixing..."
    chmod +x scripts/deploy.sh
fi

# Validate Terraform configuration
echo ""
echo "🔧 Validating Terraform configuration..."
if terraform validate; then
    echo "✅ Terraform configuration is valid"
else
    echo "❌ Terraform configuration has errors"
    exit 1
fi

# Check for terraform.tfvars
if [ ! -f "terraform.tfvars" ]; then
    echo ""
    echo "⚠️  Warning: terraform.tfvars not found"
    echo "For local development, create terraform.tfvars with your AWS credentials:"
    echo "  cp terraform.tfvars.example terraform.tfvars"
    echo "  # Then edit terraform.tfvars with your actual values"
else
    echo "✅ terraform.tfvars found"
fi

echo ""
echo "🎉 Setup validation completed!"
echo ""
echo "Next steps:"
echo "1. Configure GitHub secrets and variables (for CI/CD)"
echo "2. Or create terraform.tfvars for local development"
echo "3. Run: terraform init"
echo "4. Run: terraform plan -var-file=config/dev_config.tfvars"
echo "5. Run: terraform apply -var-file=config/dev_config.tfvars"
echo ""
echo "For CI/CD deployment, push to main branch or create deploy-* tags" 