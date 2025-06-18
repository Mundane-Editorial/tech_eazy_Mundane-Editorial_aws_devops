# 🚀 EC2 Deployment with Terraform and GitHub Actions

This project provisions an EC2 instance on AWS using Terraform and deploys a Java web application accessible on port `8080`. It includes automated CI/CD pipeline using GitHub Actions.

---

## 📆 Project Structure

```
tech_eazy_Mundane-Editorial_aws_devops/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD pipeline
├── ec2_deployment/
│   ├── config/
│   │   ├── dev_config.tfvars   # Development environment variables
│   │   └── prod_config.tfvars  # Production environment variables
│   ├── key_pair/
│   │   └── id_rsa.pub          # Public SSH key (private key not in repo)
│   ├── scripts/
│   │   ├── deploy.sh           # Manual deployment script
│   │   └── setup.sh            # EC2 instance setup script
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Terraform variables
│   ├── outputs.tf              # Terraform outputs
│   ├── provider.tf             # Terraform provider configuration
│   ├── resources.tf            # Security groups and key pairs
│   ├── IAM_roles.tf            # IAM roles and policies
│   └── s3_bucket.tf            # S3 bucket configuration
├── .gitignore                  # Git ignore rules
└── README.md                   # This file
```

---

## 🚀 Features

### ✅ Infrastructure as Code (Terraform)
- **EC2 Instance**: Ubuntu-based instance with configurable type and AMI
- **Security Groups**: Configured for SSH (22), HTTP (80), and Java app (8080)
- **IAM Roles**: Secure instance profile with S3 upload permissions
- **S3 Bucket**: Artifact storage with lifecycle policies
- **Key Pairs**: SSH key management for secure access

### ✅ Automated CI/CD (GitHub Actions)
- **Trigger Methods**:
  - Push to `main` branch → Production deployment
  - Push to `feature/*` branches → Development deployment
  - Tags `deploy-dev` or `deploy-prod` → Stage-specific deployment
  - Manual workflow dispatch with stage selection
- **Automated Steps**:
  - Terraform infrastructure provisioning
  - SSH-based application deployment
  - Health checks on port 8080
  - Log upload to S3
  - Automatic cleanup on failure

### ✅ Application Deployment
- **Java Application**: Deployed from GitHub repository
- **Health Monitoring**: Automated health checks post-deployment
- **Log Management**: Application and EC2 logs uploaded to S3
- **Auto-shutdown**: Configurable shutdown threshold for cost management

---

## 📦 Prerequisites

- **Terraform** (v1.0+) installed: [Download Terraform](https://www.terraform.io/downloads)
- **AWS Account** with programmatic access and EC2/VPC permissions
- **GitHub Repository** with secrets configured

---

## 🛠️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/Mundane-Editorial/tech_eazy_Mundane-Editorial_aws_devops.git
cd tech_eazy_Mundane-Editorial_aws_devops/ec2_deployment
```

### 2. Generate SSH Key Pair

```bash
ssh-keygen -t rsa -b 2048 -f key_pair/id_rsa -N ""
```

### 3. Configure GitHub Secrets

In your GitHub repository, go to **Settings → Secrets and variables → Actions** and add:

**Secrets:**
- `ACCESS_KEY_VALUE`: Your AWS access key
- `SECRET_KEY_VALUE`: Your AWS secret key
- `EC2_PRIVATE_KEY`: Content of your private key file (`key_pair/id_rsa`)
- `EC2_PUBLIC_KEY`: Content of your public key file (`key_pair/id_rsa.pub`)

**Variables:**
- `AWS_REGION`: `ap-south-1` (or your preferred region)
- `BUCKET_NAME`: `your-deployment-bucket`
- `INSTANCE_USER`: `ubuntu`
- `AMI_ID`: `ami-02521d90e7410d9f0` (Ubuntu AMI)
- `INSTANCE_TYPE`: `t2.micro`
- `JAVA_VERSION`: `21`
- `REPO_URL`: `https://github.com/techeazy-consulting/techeazy-devops`
- `SHUTDOWN_THRESHOLD`: `20`

### 4. Local Development Setup

For local development and testing:

```bash
# Initialize Terraform
terraform init

# Create terraform.tfvars (DO NOT COMMIT THIS FILE)
cat > terraform.tfvars << EOF
access_key_value = "YOUR_AWS_ACCESS_KEY"
secret_key_value = "YOUR_AWS_SECRET_KEY"
ec2_private_key  = "$(cat key_pair/id_rsa)"
ec2_public_key   = "$(cat key_pair/id_rsa.pub)"
EOF

# Validate configuration
terraform validate

# Plan deployment
terraform plan -var-file="config/dev_config.tfvars"

# Apply configuration
terraform apply -var-file="config/dev_config.tfvars"
```

---

## 🚀 Deployment Methods

### Method 1: GitHub Actions (Recommended)

**Automatic Deployment:**
- Push to `main` branch → Production deployment
- Push to `feature/*` branch → Development deployment
- Create tag `deploy-dev` or `deploy-prod` → Stage-specific deployment

**Manual Deployment:**
1. Go to **Actions** tab in GitHub
2. Select **JAVA Application Deployment** workflow
3. Click **Run workflow**
4. Select stage (dev/prod) and click **Run workflow**

### Method 2: Manual Deployment

```bash
# Deploy to development
./scripts/deploy.sh dev <EC2_IP>

# Deploy to production
./scripts/deploy.sh prod <EC2_IP>
```

### Method 3: Terraform Direct

```bash
# Development
terraform apply -var-file="config/dev_config.tfvars"

# Production
terraform apply -var-file="config/prod_config.tfvars"
```

---

## 🔍 Monitoring and Validation

### Health Check
The application is automatically validated after deployment:
- **Port Check**: Verifies port 8080 is accessible
- **Response Check**: Confirms application is responding
- **Retry Logic**: 20 attempts with 10-second intervals

### Logs
- **Application Logs**: Stored in `/app/logs/` on EC2 and uploaded to S3
- **EC2 Logs**: Uploaded to S3 on instance shutdown
- **Deployment Logs**: GitHub Actions logs uploaded to S3

### Access the Application
After successful deployment, access your application at:
```
http://<EC2_PUBLIC_IP>:8080
```

---

## 🧹 Cleanup

### Destroy Infrastructure
```bash
# Development
terraform destroy -var-file="config/dev_config.tfvars"

# Production
terraform destroy -var-file="config/prod_config.tfvars"
```

### Automatic Cleanup
GitHub Actions automatically destroys infrastructure if deployment fails.

---

## ⚠️ Security Best Practices

- ✅ SSH keys are stored as GitHub secrets
- ✅ IAM roles follow principle of least privilege
- ✅ S3 buckets are private with lifecycle policies
- ✅ Security groups restrict access to necessary ports
- ✅ Sensitive files are excluded via .gitignore

---

## 🔧 Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   - Verify SSH keys are properly configured in GitHub secrets
   - Check security group allows port 22
   - Ensure instance is fully booted (wait 2-3 minutes)

2. **Health Check Failed**
   - Verify application repository is accessible
   - Check Java version compatibility
   - Review application logs in S3

3. **Terraform Errors**
   - Ensure AWS credentials are valid
   - Check region and AMI availability
   - Verify all required variables are set

### Debug Commands

```bash
# Check Terraform state
terraform show

# View application logs
aws s3 ls s3://your-bucket/app/logs/

# SSH into instance (if needed)
ssh -i key_pair/id_rsa ubuntu@<EC2_IP>
```

---

## 📝 Notes

- The application automatically shuts down after the configured threshold (default: 20 minutes)
- All logs are automatically uploaded to S3 for monitoring
- The infrastructure is designed for development/testing purposes
- For production use, consider additional security measures and monitoring

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is part of the TechEazy DevOps internship assignment.

---

## final steps to validate github actions 

- push updated code to any of the branch and it will trigger CI/CD

---
