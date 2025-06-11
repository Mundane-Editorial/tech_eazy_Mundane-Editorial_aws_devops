# 🚀 EC2 Deployment with Terraform

This project provisions an EC2 instance on AWS using Terraform and deploys a Java web application accessible on port `8080`.

---

## 📆 Project Structure

```
TechEazy-internship/
└── ec2_deployment
    ├── config
    │   └── dev_config.tfvars  //configure your variables here
    ├── key_pair
    │   ├── id_rsa
    │   └── id_rsa.pub
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── resources.tf
    ├── scripts
    │   ├── deploy.sh
    │   └── setup.sh
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    ├── terraform.tfvars
    └── variables.tf
```
---

## 📦 Prerequisites

- Terraform installed: [Download Terraform](https://www.terraform.io/downloads)
- AWS IAM user with programmatic access and EC2/VPC permissions

---

## 🛠️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/Mundane-Editorial/tech_eazy_Mundane-Editorial_aws_devops.git
cd tech_eazy_Mundane-Editorial_aws_devops/ec2_deployment
```

### 2. Open Ec2_deployment and Initialize Terraform into it using 

```bash
terraform init
```

### 3. Provide AWS Credentials

Create a file named `terraform.tfvars` in the `ec2_deployment` folder and add your AWS access keys:

```hcl
access_key_value  = "YOUR_AWS_ACCESS_KEY"
secret_key_value  = "YOUR_AWS_SECRET_KEY"
```

> **Note**: Do NOT commit this file to version control.

---

### 4. Generate SSH Key Pair

Generate an RSA key pair to access the EC2 instance:

```bash
ssh-keygen -t rsa
```

When prompted, press `Enter` to accept defaults and leave the passphrase empty.

Move the generated keys to the `key_pair` folder:

```bash
mkdir -p key_pair
mv ~/.ssh/id_rsa key_pair/dev_key
mv ~/.ssh/id_rsa.pub key_pair/dev_key.pub
```

---

### 5. Validate Configuration

```bash
terraform validate
```

---

### 6. Plan the Deployment

```bash
terraform plan
```

---

### 7. Apply the Configuration

```bash
terraform apply -var-file="config/dev_config.tfvars"
```

Or use your own `.tfvars` file with the required variables.

---

### 8. Access the Java Web Application

After successful apply, retrieve the instance public IP:

```bash
terraform output
```

Then open your browser:

```
http://<ec2_public_ip>:8080
```

You should see the deployed Java application.

---

## 🧹 Teardown Resources

When done, destroy the resources:

```bash
terraform destroy -var-file="config/dev_config.tfvars"
```

---

## ⚠️ Security Notice

- Never commit your `terraform.tfvars` or private key (`dev_key`) to GitHub.
- Use `.gitignore` to ignore sensitive files.

---

## 📁 Sample `.gitignore`

```gitignore
terraform.tfvars
.terraform.lock.hcl
.terraform

terraform.tfstate
terraform.tfstate.backup

key_pair/id_rsa
key_pair/id_rsa.pub

.terraform.tfstate.lock.info
```

---
