# 🚀 Jenkins + Terraform + AWS CI/CD Pipeline — Complete Guide

## 📌 Project Overview

This guide explains how to build a basic CI/CD pipeline using:

- 🔧 Jenkins
- 🏗️ Terraform
- ☁️ AWS
- 🐙 GitHub
- 🐧 Ubuntu EC2

The goal is to automatically deploy Terraform infrastructure through Jenkins.

### Final Architecture

```text
                    ☁️ AWS
                      │
                      │ IAM Role
                      ▼
🐙 GitHub ───────► 🔧 Jenkins EC2
                      │
                      │ Jenkinsfile
                      ▼
                  🏗️ Terraform
                      │
                      ▼
                 ☁️ AWS Resources
Pipeline Flow
Developer
    │
    │ git push
    ▼
GitHub
    │
    │ Jenkins checkout
    ▼
Jenkins
    │
    ├── Checkout
    ├── Terraform Init
    ├── Terraform Validate
    ├── Terraform Plan
    └── Terraform Apply
             │
             ▼
          AWS
🧰 Prerequisites

Before starting, make sure you have:

✅ AWS Account
✅ Ubuntu EC2 instance
✅ Jenkins installed
✅ Terraform installed
✅ Git installed
✅ GitHub account
✅ Basic Linux knowledge

Example environment:

Operating System : Ubuntu
Cloud            : AWS
Region           : ap-south-1
CI/CD Tool       : Jenkins
Infrastructure   : Terraform
Source Control   : GitHub
Terraform Demo   : AWS S3 Bucket
1️⃣ Connect to the Jenkins EC2 Server

Connect to your Ubuntu EC2 instance:

ssh ubuntu@<JENKINS-EC2-IP>

Example:

ssh ubuntu@13.201.10.20
2️⃣ Verify Jenkins Installation

Check Jenkins status:

sudo systemctl status jenkins

You should see:

Active: active (running)

If Jenkins is not running:

sudo systemctl start jenkins

Enable Jenkins to start automatically after reboot:

sudo systemctl enable jenkins

Check Jenkins version:

jenkins --version

Jenkins should be accessible from:

http://<JENKINS-IP>:8080

Example:

http://13.201.10.20:8080
3️⃣ Verify Terraform Installation

Check Terraform:

terraform version

Example:

Terraform v1.x.x

Now check whether the Jenkins user can access Terraform:

sudo -u jenkins terraform version

This is important because Jenkins executes pipeline commands using the Jenkins user.

If this command returns the Terraform version, Jenkins can use Terraform.

4️⃣ Install and Verify Git

Check Git:

git --version

If Git is not installed:

sudo apt update
sudo apt install -y git

Verify:

git --version

Example:

git version 2.x.x
5️⃣ Install AWS CLI

Check AWS CLI:

aws --version

If it is not installed:

sudo apt update
sudo apt install -y awscli

Verify:

aws --version
6️⃣ Configure AWS IAM Role for Jenkins 🔐
Why do we need an IAM Role?

Terraform needs AWS permissions to create and manage infrastructure.

Instead of storing AWS Access Keys inside Jenkins, we will attach an IAM Role to the Jenkins EC2 instance.

The architecture is:

Jenkins EC2
     │
     ▼
IAM Role
     │
     ▼
AWS Permissions
     │
     ▼
Terraform
     │
     ▼
AWS Resources

This is the recommended approach when Jenkins is running on an AWS EC2 instance.

7️⃣ Create the IAM Role

Open:

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

Then:

Use case:
EC2

Click:

Next
8️⃣ Add Permissions to the IAM Role

For a basic learning environment, you can temporarily select:

AdministratorAccess

⚠️ Important:

Do not use AdministratorAccess in production.

For production, create a least-privilege IAM policy that allows only the AWS resources Terraform needs.

Click:

Next

Then:

Next
9️⃣ Name the IAM Role

Use:

JenkinsTerraformRole

Click:

Create role

The IAM role is now created.

🔟 Attach IAM Role to Jenkins EC2

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

The IAM role is now attached to the Jenkins EC2 instance.

1️⃣1️⃣ Test AWS Access

Return to the Jenkins EC2 server.

Run:

aws sts get-caller-identity

You should receive output similar to:

{
    "UserId": "...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:role/JenkinsTerraformRole"
}

Now test specifically as the Jenkins user:

sudo -u jenkins aws sts get-caller-identity

If this command works, Jenkins has AWS access.

1️⃣2️⃣ Create the Terraform Project

Create a project directory:

mkdir ~/terraform-jenkins
cd ~/terraform-jenkins

The project structure will be:

terraform-jenkins/
│
├── provider.tf
├── main.tf
└── Jenkinsfile
1️⃣3️⃣ Create provider.tf

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

Save:

Ctrl + O
Enter
Ctrl + X
1️⃣4️⃣ Create main.tf

Create:

nano main.tf

Add:

resource "aws_s3_bucket" "demo" {
  bucket = "sourabh-terraform-jenkins-demo-123456789"
}

⚠️ S3 bucket names must be globally unique.

If this name already exists, change it.

Example:

resource "aws_s3_bucket" "demo" {
  bucket = "my-terraform-jenkins-demo-987654321"
}
1️⃣5️⃣ Test Terraform Manually

Go to the Terraform directory:

cd ~/terraform-jenkins

Initialize Terraform:

terraform init

Validate the configuration:

terraform validate

Create a plan:

terraform plan

Expected result:

Plan: 1 to add, 0 to change, 0 to destroy.

At this point:

Terraform
    │
    ├── Configuration ✅
    ├── AWS Provider   ✅
    └── AWS Access     ✅
1️⃣6️⃣ Optional: Test Terraform Apply Manually

You can test the Terraform deployment before using Jenkins.

Run:

terraform apply

Terraform will ask:

Do you want to perform these actions?

Type:

yes

Terraform will create the S3 bucket.

Verify it in:

AWS Console
    ↓
S3
    ↓
Buckets

After testing, you can destroy the resource:

terraform destroy

Type:

yes

This removes the test infrastructure.

1️⃣7️⃣ Create GitHub Repository 🐙

Go to GitHub and create a new repository:

terraform-jenkins

You can keep it private or public.

The repository will contain:

terraform-jenkins/
│
├── provider.tf
├── main.tf
└── Jenkinsfile
1️⃣8️⃣ Configure Git

Go to the Terraform project:

cd ~/terraform-jenkins

Initialize Git:

git init

Add your GitHub repository:

git remote add origin https://github.com/YOUR_USERNAME/terraform-jenkins.git

Verify:

git remote -v
1️⃣9️⃣ Push Terraform Files to GitHub

Add the files:

git add .

Commit:

git commit -m "Add Terraform configuration"

Set the main branch:

git branch -M main

Push:

git push -u origin main

Your Terraform files are now available on GitHub.

2️⃣0️⃣ Create the Jenkinsfile 🔧

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
2️⃣1️⃣ Push Jenkinsfile to GitHub

Add the Jenkinsfile:

git add Jenkinsfile

Commit:

git commit -m "Add Jenkins Terraform pipeline"

Push:

git push origin main

Your GitHub repository should now look like:

terraform-jenkins/
│
├── Jenkinsfile
├── main.tf
└── provider.tf
2️⃣2️⃣ Create Jenkins Pipeline

Open Jenkins:

http://<JENKINS-IP>:8080

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
2️⃣3️⃣ Configure GitHub Repository in Jenkins

Scroll down to the:

Pipeline

section.

For:

Definition

select:

Pipeline script from SCM

For:

SCM

select:

Git

Repository URL:

https://github.com/YOUR_USERNAME/terraform-jenkins.git

Branch:

*/main

Script Path:

Jenkinsfile

The configuration should look like:

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

Click:

Save
2️⃣4️⃣ Run the Jenkins Pipeline ▶️

Open:

Jenkins
    ↓
terraform-jenkins

Click:

Build Now

Jenkins will automatically execute:

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
2️⃣5️⃣ Check Jenkins Console Output

Open:

Build #1
    ↓
Console Output

You should see:

[Pipeline] stage
[Pipeline] { (Checkout)

[Pipeline] stage
[Pipeline] { (Terraform Init)

[Pipeline] stage
[Pipeline] { (Terraform Validate)

[Pipeline] stage
[Pipeline] { (Terraform Plan)

[Pipeline] stage
[Pipeline] { (Terraform Apply)

At the end:

Finished: SUCCESS

🎉 Your Jenkins + Terraform deployment is working.

2️⃣6️⃣ Verify AWS Resource ☁️

Go to:

AWS Console
    ↓
S3
    ↓
Buckets

You should see the S3 bucket created by Terraform.

This confirms:

🐙 GitHub
     ↓
🔧 Jenkins
     ↓
🏗️ Terraform
     ↓
☁️ AWS
2️⃣7️⃣ Complete Project Structure

Your GitHub repository should contain:

terraform-jenkins/
│
├── Jenkinsfile
├── main.tf
└── provider.tf
provider.tf
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
main.tf
resource "aws_s3_bucket" "demo" {
  bucket = "YOUR-UNIQUE-BUCKET-NAME"
}
Jenkinsfile
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
2️⃣8️⃣ Destroy Test Infrastructure 🧹

When you finish testing, destroy the Terraform resource:

cd ~/terraform-jenkins
terraform destroy

Confirm:

yes

⚠️ Never run terraform destroy against production infrastructure unless you intentionally want to delete it.

🔐 Important Security Notes
❌ Do not put AWS Access Keys in Jenkinsfile

Never do this:

environment {
    AWS_ACCESS_KEY_ID = 'xxxxxxxx'
    AWS_SECRET_ACCESS_KEY = 'xxxxxxxx'
}

Use an EC2 IAM Role instead.

❌ Do not commit secrets to GitHub

Never commit:

AWS Access Keys
AWS Secret Keys
Passwords
Private Keys
API Tokens
Terraform secret variables
⚠️ AdministratorAccess

AdministratorAccess is acceptable for a temporary learning environment, but it should be replaced with a least-privilege IAM policy before using this setup in production.

📋 Final Checklist
 Jenkins installed
 Jenkins service running
 Terraform installed
 Terraform available to Jenkins user
 Git installed
 AWS CLI installed
 IAM Role created
 IAM Role attached to Jenkins EC2
 AWS access tested
 Jenkins AWS access tested
 Terraform project created
 provider.tf created
 main.tf created
 Terraform initialized
 Terraform validated
 Terraform plan successful
 GitHub repository created
 Terraform files pushed to GitHub
 Jenkinsfile created
 Jenkinsfile pushed to GitHub
 Jenkins Pipeline created
 GitHub repository configured in Jenkins
 Jenkins Build Now executed
 Terraform Apply successful
 AWS resource verified
🔄 Final CI/CD Architecture
                         ☁️ AWS
                           │
                           │
                    🔐 IAM Role
                           │
                           ▼
🐙 GitHub ───────────► 🔧 Jenkins
                           │
                           │
                           ▼
                     🏗️ Terraform
                           │
                           │
                           ▼
                    ☁️ AWS Resources
🚀 Next Improvements

Once this basic pipeline is working successfully, improve it step by step.

Phase 1 — Automation
GitHub
   ↓
Webhook
   ↓
Jenkins
   ↓
Terraform

A Git push will automatically trigger Jenkins.

Phase 2 — Terraform State

Use:

Amazon S3

for remote Terraform state.

Phase 3 — Approval

Add:

Terraform Plan
      ↓
Manual Approval
      ↓
Terraform Apply
Phase 4 — Environments

Create:

Development
     ↓
Staging
     ↓
Production
Phase 5 — Security

Add:

Terraform Security Scan
        ↓
Secret Scanning
        ↓
Least-Privilege IAM
Phase 6 — Monitoring and Notifications

Add:

Jenkins
   ↓
Monitoring
   ↓
Notifications
🎯 Final Goal

The production-style pipeline can eventually become:

👨‍💻 Developer
      │
      │ git push
      ▼
🐙 GitHub
      │
      │ Webhook
      ▼
🔧 Jenkins
      │
      ├── 📥 Checkout
      │
      ├── 🔍 Validate
      │
      ├── 🏗️ Terraform Init
      │
      ├── 📋 Terraform Plan
      │
      ├── ✋ Manual Approval
      │
      └── 🚀 Terraform Apply
                │
                ▼
             ☁️ AWS
