Here is the complete guide formatted in raw Markdown. You can easily copy and paste it into a README.md file using the Copy button in the top corner of the code block below:

Markdown
# AWS Infrastructure Automation with Jenkins & Terraform (IAM Role Auth) 🚀

A complete step-by-step hands-on guide to building an automated CI/CD infrastructure pipeline. This guide demonstrates how to configure a Jenkins EC2 instance using **IAM Roles** (eliminating static access keys), define infrastructure with **Terraform**, version-control via **GitHub**, and execute end-to-end automated deployments via a **Jenkins Pipeline**.

---

## 🏗️ Architecture Overview

```text
               +----------------------------------+
               |            AWS Cloud             |
               |                                  |
               |   +--------------------------+   |
               |   |   IAM Role               |   |
               |   |   (AdministratorAccess)  |   |
               |   +------------+-------------+   |
               |                | (Attached)      |
               |                v                 |
+----------+   |   +--------------------------+   |   +-----------------+
|  GitHub  | --> |  Jenkins EC2 Instance    | --> |  AWS Resources  |
|  Repo    |   |   |  - Git                   |   |   (e.g., S3     |
+----------+   |   |  - Terraform CLI         |   |    Bucket)      |
               |   +--------------------------+   |   +-----------------+
               +----------------------------------+
🔁 Pipeline Execution Flow
Plaintext
GitHub Push ──► Jenkins Checkout ──► Terraform Init ──► Terraform Validate ──► Terraform Plan ──► Terraform Apply ──► AWS Resource Provisioned
📋 Prerequisites
Before starting, ensure you have:

An active AWS Account.

An EC2 Instance running Ubuntu with Jenkins and Terraform pre-installed.

Git installed locally and configured.

A GitHub Account for remote repository hosting.

🚀 Step-by-Step Implementation
Step 1: Create an IAM Role for Jenkins EC2 🛡️
Instead of hardcoding AWS credentials inside Jenkins or Terraform, we use an IAM Role attached directly to the EC2 instance for secure, keyless authentication.

Log in to the AWS Management Console.

Navigate to IAM ➔ Roles ➔ click Create role.

Under Select trusted entity:

Trusted entity type: Select AWS service.

Use case: Select EC2.

Click Next.

Under Add permissions:

Search for and select AdministratorAccess.

Note: In production environments, follow the principle of least privilege. AdministratorAccess is used here for sandbox/learning purposes.

Click Next.

Set Role name:

Enter JenkinsTerraformRole.

Click Create role.

Step 2: Attach the IAM Role to the Jenkins EC2 Instance 🔗
Navigate to EC2 ➔ Instances in the AWS Console.

Select your running Jenkins EC2 instance.

Click Actions ➔ Security ➔ Modify IAM role.

From the dropdown list, select JenkinsTerraformRole.

Click Update IAM role.

Step 3: Verify AWS Credentials on the Jenkins Server 🧪
SSH into your Jenkins EC2 instance:

Bash
ssh ubuntu@YOUR_EC2_PUBLIC_IP
Test AWS CLI connectivity as the default user (ubuntu):

Bash
aws sts get-caller-identity
Crucial Step: Test AWS CLI connectivity as the jenkins system user to ensure Jenkins has access to the IAM Role credentials:

Bash
sudo -u jenkins aws sts get-caller-identity
Expected Output:

JSON
{
    "UserId": "AROAXXXXXXXXXXXXXXXXX:i-0123456789abcdef0",
    "Account": "123456789012",
    "Arn": "arn:aws:sts::123456789012:assumed-role/JenkinsTerraformRole/i-0123456789abcdef0"
}
If both commands return your Account ID and Role ARN, the security configuration is complete!

Step 4: Set Up the Terraform Workspace 📁
On your Jenkins server, create a dedicated project directory:

Bash
mkdir -p ~/terraform-jenkins && cd ~/terraform-jenkins
Create the provider configuration file (provider.tf):

Bash
nano provider.tf
Add the following code:

Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
Step 5: Define Infrastructure Resources 📦
Create the main configuration file (main.tf):

Bash
nano main.tf
Define an S3 bucket resource (ensure the bucket name is globally unique):

Terraform
resource "aws_s3_bucket" "demo" {
  bucket = "sourabh-terraform-demo-123456789"

  tags = {
    Name        = "Terraform Demo Bucket"
    Environment = "Dev"
    ManagedBy   = "Jenkins"
  }
}
Step 6: Test Terraform Manually 🛠️
Before automating through Jenkins, manually verify the Terraform workflow:

Initialize the directory to download provider plugins:

Bash
terraform init
Validate syntax and configuration integrity:

Bash
terraform validate
Preview the changes:

Bash
terraform plan
Verify output displays: Plan: 1 to add, 0 to change, 0 to destroy.

Apply the configuration to create the resource:

Bash
terraform apply -auto-approve
Step 7: Create a GitHub Repository 🐙
Go to GitHub and create a new repository named terraform-jenkins.

Keep the repository public or private, and leave it empty (without initializing README or .gitignore).

Step 8: Create the Declarative Jenkinsfile 📄
In your project directory (~/terraform-jenkins), create the pipeline script:

Bash
nano Jenkinsfile
Paste the following Declarative Pipeline script:

Groovy
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
        always {
            cleanWs()
        }
    }
}
Step 9: Version Control & Push to GitHub 📤
Ensure Git is installed:

Bash
sudo apt update && sudo apt install -y git
Initialize Git and commit code:

Bash
cd ~/terraform-jenkins
git init
git branch -M main
git add .
git commit -m "feat: initial terraform pipeline configuration"
Link the remote repository and push code:

Bash
git remote add origin [https://github.com/YOUR_USERNAME/terraform-jenkins.git](https://github.com/YOUR_USERNAME/terraform-jenkins.git)
git push -u origin main
(Use a Personal Access Token [PAT] if prompted for GitHub authentication).

Step 10: Create a Pipeline Job in Jenkins ⚙️
Open your Jenkins Dashboard in the web browser.

Click New Item.

Enter Item Name: terraform-jenkins.

Select Pipeline.

Click OK.

Step 11: Configure Pipeline SCM Settings ⚙️
Scroll down to the Pipeline section.

Select Definition: Pipeline script from SCM.

Select SCM: Git.

Enter Repository URL: https://github.com/YOUR_USERNAME/terraform-jenkins.git.

Set Branch Specifier: */main.

Set Script Path: Jenkinsfile.

Click Save.

Step 12: Trigger the Pipeline Run 🚀
Click Build Now on the left menu of your Jenkins project page.

Monitor the stage view as Jenkins runs:

Checkout ➔ Terraform Init ➔ Terraform Validate ➔ Terraform Plan ➔ Terraform Apply.

Check the Console Output to confirm execution details:

Plaintext
Finished: SUCCESS
Step 13: Verify Provisioned Resources in AWS Console 🔎
Open the AWS Management Console.

Navigate to S3 ➔ Buckets.

Verify that your bucket (sourabh-terraform-demo-123456789) is listed and active.

🧹 Cleanup / Teardown (Optional) 🗑️
To avoid unexpected charges on AWS, destroy the created infrastructure when finished:

Bash
cd ~/terraform-jenkins
terraform destroy -auto-approve
