# Jenkins + Terraform + AWS CI/CD Pipeline — Complete Setup

## Overview

This guide explains how to create a basic CI/CD pipeline using Jenkins, Terraform, AWS, GitHub, and Ubuntu EC2.

Final workflow:

Developer → GitHub → Jenkins → Terraform → AWS

---

## 1. Prerequisites

Make sure you have:

- AWS Account
- Ubuntu EC2 instance
- Jenkins installed
- Terraform installed
- Git installed
- GitHub account
- SSH access to the Jenkins EC2

Example environment:

- Operating System: Ubuntu
- Cloud: AWS
- Region: ap-south-1
- CI/CD Tool: Jenkins
- Infrastructure Tool: Terraform
- Source Control: GitHub
- Demo Resource: AWS S3 Bucket

---

## 2. Connect to Jenkins EC2

Connect to your Jenkins EC2 server:

    ssh ubuntu@<JENKINS-EC2-IP>

Example:

    ssh ubuntu@13.201.10.20

---

## 3. Verify Jenkins

Check Jenkins:

    sudo systemctl status jenkins

Expected:

    Active: active (running)

If Jenkins is not running:

    sudo systemctl start jenkins

Enable Jenkins at startup:

    sudo systemctl enable jenkins

Check Jenkins version:

    jenkins --version

Open Jenkins:

    http://<JENKINS-EC2-IP>:8080

Make sure port 8080 is allowed in the EC2 Security Group.

---

## 4. Verify Terraform

Check Terraform:

    terraform version

Now check Terraform using the Jenkins user:

    sudo -u jenkins terraform version

This is important because Jenkins executes pipeline commands using the Jenkins user.

If the Terraform version is displayed, Jenkins can access Terraform.

---

## 5. Install and Verify Git

Check Git:

    git --version

If Git is not installed:

    sudo apt update
    sudo apt install -y git

Verify:

    git --version

---

## 6. Install and Verify AWS CLI

Check AWS CLI:

    aws --version

If AWS CLI is not installed:

    sudo apt update
    sudo apt install -y awscli

Verify:

    aws --version

---

## 7. Configure AWS Access for Jenkins

Terraform needs permission to create AWS resources.

Because Jenkins is running on an AWS EC2 instance, use an IAM Role attached to the EC2 instance.

Architecture:

    Jenkins EC2
         |
         v
      IAM Role
         |
         v
    AWS Permissions
         |
         v
      Terraform
         |
         v
    AWS Resources

Do not store AWS Access Keys directly inside the Jenkinsfile.

---

## 8. Create IAM Role

Open AWS Console:

    AWS Console
        ↓
    IAM
        ↓
    Roles
        ↓
    Create role

Select:

    Trusted entity type:
    AWS service

Select:

    Use case:
    EC2

Click Next.

---

## 9. Add IAM Permissions

For a simple learning environment, temporarily select:

    AdministratorAccess

IMPORTANT:

Do not use AdministratorAccess in production.

For production, create a least-privilege IAM policy containing only the permissions required by Terraform.

Click Next and create the role.

---

## 10. Name the IAM Role

Use:

    JenkinsTerraformRole

Click:

    Create role

The IAM Role is now created.

---

## 11. Attach IAM Role to Jenkins EC2

Go to:

    AWS Console
        ↓
    EC2
        ↓
    Instances

Select the EC2 instance where Jenkins is installed.

Then:

    Actions
        ↓
    Security
        ↓
    Modify IAM role

Select:

    JenkinsTerraformRole

Click:

    Update IAM role

The IAM Role is now attached to the Jenkins EC2 instance.

---

## 12. Test AWS Access

Run:

    aws sts get-caller-identity

Expected output:

    {
        "UserId": "...",
        "Account": "123456789012",
        "Arn": "arn:aws:iam::123456789012:role/JenkinsTerraformRole"
    }

Now test specifically as the Jenkins user:

    sudo -u jenkins aws sts get-caller-identity

If this command works, Jenkins has AWS access.

---

## 13. Create Terraform Project

Create the project directory:

    mkdir -p ~/terraform-jenkins
    cd ~/terraform-jenkins

Project structure:

    terraform-jenkins/
    ├── provider.tf
    ├── main.tf
    └── Jenkinsfile

---

## 14. Create provider.tf

Create the file:

    nano provider.tf

Add:

    terraform {
      required_providers {
        aws = {
          source = "hashicorp/aws"
        }
      }
    }

    provider "aws" {
      region = "ap-south-1"
    }

Save with:

    Ctrl + O
    Enter
    Ctrl + X

---

## 15. Create main.tf

Create:

    nano main.tf

Add:

    resource "aws_s3_bucket" "demo" {
      bucket = "my-terraform-jenkins-demo-123456789"
    }

IMPORTANT:

S3 bucket names must be globally unique.

If the bucket already exists, change the name.

Example:

    resource "aws_s3_bucket" "demo" {
      bucket = "my-terraform-jenkins-demo-987654321"
    }

---

## 16. Test Terraform Manually

Go to the project:

    cd ~/terraform-jenkins

Initialize Terraform:

    terraform init

Validate:

    terraform validate

Create a plan:

    terraform plan

Expected:

    Plan: 1 to add, 0 to change, 0 to destroy.

This confirms:

- Terraform is installed
- AWS provider works
- AWS authentication works
- Terraform configuration is valid

---

## 17. Optional Terraform Apply Test

You can test Terraform manually before using Jenkins:

    terraform apply

Terraform will ask for confirmation.

Enter:

    yes

Verify the S3 bucket:

    AWS Console
        ↓
    S3
        ↓
    Buckets

After testing, remove the resource:

    terraform destroy

Enter:

    yes

This step is optional.

---

## 18. Create GitHub Repository

Create a new GitHub repository named:

    terraform-jenkins

The repository will contain:

    terraform-jenkins/
    ├── Jenkinsfile
    ├── main.tf
    └── provider.tf

---

## 19. Configure Git

Go to the Terraform project:

    cd ~/terraform-jenkins

Initialize Git:

    git init

Add your GitHub repository:

    git remote add origin https://github.com/YOUR_USERNAME/terraform-jenkins.git

Verify:

    git remote -v

---

## 20. Push Terraform Files to GitHub

Add files:

    git add .

Commit:

    git commit -m "Add Terraform configuration"

Set the main branch:

    git branch -M main

Push:

    git push -u origin main

If GitHub asks for authentication, use your GitHub authentication method or Personal Access Token.

---

## 21. Create Jenkinsfile

Create the Jenkinsfile:

    nano Jenkinsfile

Add:

    pipeline {

        agent any

        stages {

            stage('Checkout') {
                steps {
                    checkout scm
                }
            }

            stage('Terraform Init') {
                steps {
                    sh 'terraform init'
                }
            }

            stage('Terraform Validate') {
                steps {
                    sh 'terraform validate'
                }
            }

            stage('Terraform Plan') {
                steps {
                    sh 'terraform plan'
                }
            }

            stage('Terraform Apply') {
                steps {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        post {
            success {
                echo 'Terraform deployment completed successfully!'
            }

            failure {
                echo 'Terraform deployment failed!'
            }
        }
    }

Save:

    Ctrl + O
    Enter
    Ctrl + X

---

## 22. Push Jenkinsfile to GitHub

Run:

    git add Jenkinsfile

Commit:

    git commit -m "Add Jenkins Terraform pipeline"

Push:

    git push origin main

Your GitHub repository should now contain:

    terraform-jenkins/
    ├── Jenkinsfile
    ├── main.tf
    └── provider.tf

---

## 23. Create Jenkins Pipeline

Open Jenkins:

    http://<JENKINS-EC2-IP>:8080

Go to:

    Jenkins
        ↓
    New Item

Enter:

    terraform-jenkins

Select:

    Pipeline

Click:

    OK

---

## 24. Configure GitHub Repository in Jenkins

Scroll down to the Pipeline section.

For Definition select:

    Pipeline script from SCM

For SCM select:

    Git

Repository URL:

    https://github.com/YOUR_USERNAME/terraform-jenkins.git

Branch:

    */main

Script Path:

    Jenkinsfile

The configuration should be:

    Definition:
    Pipeline script from SCM

    SCM:
    Git

    Repository URL:
    https://github.com/YOUR_USERNAME/terraform-jenkins.git

    Branch:
    */main

    Script Path:
    Jenkinsfile

Click Save.

---

## 25. Run Jenkins Pipeline

Open:

    Jenkins
        ↓
    terraform-jenkins

Click:

    Build Now

Jenkins will execute:

    Checkout
        ↓
    Terraform Init
        ↓
    Terraform Validate
        ↓
    Terraform Plan
        ↓
    Terraform Apply
        ↓
    AWS

---

## 26. Check Console Output

Open:

    Build #1
        ↓
    Console Output

You should see:

    Checkout
    Terraform Init
    Terraform Validate
    Terraform Plan
    Terraform Apply

At the end:

    Finished: SUCCESS

This means the Jenkins + Terraform pipeline is working.

---

## 27. Verify AWS Resource

Go to:

    AWS Console
        ↓
    S3
        ↓
    Buckets

You should see the S3 bucket created by Terraform.

The complete flow is:

    GitHub
       ↓
    Jenkins
       ↓
    Terraform
       ↓
    AWS

---

## 28. Complete Project Structure

Your GitHub repository should contain:

    terraform-jenkins/
    ├── Jenkinsfile
    ├── main.tf
    └── provider.tf

### provider.tf

    terraform {
      required_providers {
        aws = {
          source = "hashicorp/aws"
        }
      }
    }

    provider "aws" {
      region = "ap-south-1"
    }

### main.tf

    resource "aws_s3_bucket" "demo" {
      bucket = "YOUR-UNIQUE-BUCKET-NAME"
    }

### Jenkinsfile

    pipeline {

        agent any

        stages {

            stage('Checkout') {
                steps {
                    checkout scm
                }
            }

            stage('Terraform Init') {
                steps {
                    sh 'terraform init'
                }
            }

            stage('Terraform Validate') {
                steps {
                    sh 'terraform validate'
                }
            }

            stage('Terraform Plan') {
                steps {
                    sh 'terraform plan'
                }
            }

            stage('Terraform Apply') {
                steps {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        post {
            success {
                echo 'Terraform deployment completed successfully!'
            }

            failure {
                echo 'Terraform deployment failed!'
            }
        }
    }

---

## 29. Destroy Test Infrastructure

If this is only a test environment, remove the infrastructure when finished:

    terraform destroy

Confirm:

    yes

IMPORTANT:

Never run terraform destroy against production infrastructure unless you intentionally want to delete it.

---

# 🔐 Security Recommendations

## Do Not Store AWS Access Keys in Jenkinsfile

Never use:

    environment {
        AWS_ACCESS_KEY_ID = 'xxxxxxxx'
        AWS_SECRET_ACCESS_KEY = 'xxxxxxxx'
    }

Use the EC2 IAM Role instead.

## Do Not Commit Secrets to GitHub

Never commit:

- AWS Access Keys
- AWS Secret Keys
- Passwords
- Private Keys
- API Tokens
- Credentials

## Use Least-Privilege IAM in Production

For learning:

    AdministratorAccess

may be used temporarily.

For production:

    Jenkins
       ↓
    IAM Role
       ↓
    Least-Privilege Policy
       ↓
    Only Required AWS Permissions

---

# 📋 Final Checklist

## Jenkins

- [ ] Jenkins installed
- [ ] Jenkins service running
- [ ] Jenkins accessible on port 8080

## Terraform

- [ ] Terraform installed
- [ ] Terraform available to Jenkins user
- [ ] Terraform initialized
- [ ] Terraform validated
- [ ] Terraform plan successful

## AWS

- [ ] AWS CLI installed
- [ ] IAM Role created
- [ ] IAM Role attached to Jenkins EC2
- [ ] AWS access tested
- [ ] Jenkins AWS access tested

## GitHub

- [ ] GitHub repository created
- [ ] provider.tf pushed
- [ ] main.tf pushed
- [ ] Jenkinsfile pushed

## Jenkins Pipeline

- [ ] Pipeline job created
- [ ] Pipeline configured from SCM
- [ ] GitHub repository configured
- [ ] Branch configured as */main
- [ ] Script Path configured as Jenkinsfile
- [ ] Build Now executed
- [ ] Console Output shows Finished: SUCCESS
- [ ] AWS resource verified

---

# 🔄 Complete Architecture

                         AWS
                          │
                     IAM Role
                          │
                          ▼
GitHub ───────────► Jenkins EC2
                       │
                       │ Jenkinsfile
                       ▼
                    Terraform
                       │
                       ▼
                  AWS Resources

---

# 🚀 Recommended Next Steps

After the basic pipeline works, improve it gradually.

## 1. GitHub Webhook

Developer

    ↓

git push

    ↓

GitHub

    ↓

Webhook

    ↓

Jenkins

This automatically triggers Jenkins after a Git push.

## 2. Terraform Remote State

Use Amazon S3 for Terraform remote state:

    Jenkins
       ↓
    Terraform
       ↓
    S3 Remote State

## 3. Manual Approval

Change the pipeline to:

    Terraform Plan
         ↓
    Manual Approval
         ↓
    Terraform Apply

## 4. Multiple Environments

Create:

    Development
         ↓
    Staging
         ↓
    Production

## 5. Security Scanning

Add:

    Terraform Security Scan
            ↓
    Secret Scanning
            ↓
    Least-Privilege IAM

## 6. Notifications

Add notifications for:

- Build Success
- Build Failure
- Deployment Success
- Deployment Failure

---

# 🎯 Production-Style Pipeline Goal

The final pipeline can eventually become:

    Developer
        │
        │ git push
        ▼
    GitHub
        │
        │ Webhook
        ▼
    Jenkins
        │
        ├── Checkout
        ├── Terraform Format
        ├── Terraform Validate
        ├── Terraform Init
        ├── Terraform Plan
        ├── Manual Approval
        └── Terraform Apply
                │
                ▼
              AWS

---

# ✅ Final Result

After completing this guide, you will have a working basic CI/CD pipeline:

    GitHub
       ↓
    Jenkins
       ↓
    Terraform
       ↓
    AWS

Jenkins will:

1. Checkout Terraform code from GitHub.
2. Initialize Terraform.
3. Validate the Terraform configuration.
4. Generate a Terraform plan.
5. Apply the Terraform configuration.
6. Deploy infrastructure to AWS.
7. Report the deployment result.

This is the basic foundation for a Jenkins + Terraform DevOps pipeline.
