# 🚀 Node.js EC2 Auto Deployment with AWS CodePipeline & CodeDeploy

## 📌 Project Overview

This project deploys a **Node.js application automatically to an Ubuntu
EC2 instance** whenever code is pushed to a private GitHub repository.

### Final CI/CD Flow

``` text
Developer
   │
   │ git push
   ▼
GitHub Private Repository
   │
   │ GitHub Connection / Webhook
   ▼
AWS CodePipeline
   │
   │ Source Stage
   │
   │ Fetch source code from GitHub
   ▼
Source Artifact
   │
   │ CodePipeline stores artifact
   ▼
Temporary S3 Artifact Store
   │
   ▼
AWS CodeDeploy
   │
   │ Deployment starts
   ▼
CodeDeploy Agent on EC2
   │
   │ Downloads deployment artifact
   ▼
EC2 Ubuntu
   │
   │ Reads appspec.yml
   ▼
appspec.yml
   │
   ├── AfterInstall
   │       └── install.sh
   │
   └── ApplicationStart
           └── start.sh
   │
   ▼
Node.js Application
   │
   │ PM2
   ▼
Node.js App
   │
   │ Port 3000
   ▼
Nginx
   │
   ▼
Browser
```

# 🟢 STEP 1 --- Launch EC2 Instance

AWS Console:

``` text
EC2
→ Instances
→ Launch Instance
```

## Instance configuration

### Name

``` text
node-app-server
```

### AMI

``` text
Ubuntu Server 24.04 LTS
```

### Instance Type

For testing:

``` text
t3.micro
```

### Key Pair

Create/select:

``` text
node-app-key
```

Download the `.pem` file.

------------------------------------------------------------------------

# 🟢 STEP 2 --- EC2 Security Group

Configure inbound rules.

## Recommended final setup with Nginx

  Type           Port   Source
  ------------  ------  -----------
  SSH              22   0.0.0.0/0
  HTTP             80   0.0.0.0/0
  HTTPS            443  0.0.0.0/0
  Custom TCP       3000 0.0.0.0/0

------------------------------------------------------------------------

# 🟢 STEP 3 --- Connect to EC2

``` bash
ssh -i node-app-key.pem ubuntu@EC2_PUBLIC_IP
```

------------------------------------------------------------------------

# 🟢 STEP 4 --- Update Ubuntu

``` bash
sudo apt update -y
```

``` bash
sudo apt upgrade -y
```

------------------------------------------------------------------------

# 🟢 STEP 5 --- Install Node.js

Example using Node.js 22:

``` bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
```

Install Node.js:

``` bash
sudo apt install -y nodejs
```

Check:

``` bash
node -v
```

``` bash
npm -v
```

------------------------------------------------------------------------

# 🟢 STEP 6 --- Install PM2

``` bash
sudo npm install -g pm2
```

Check:

``` bash
pm2 -v
```

PM2 is used to keep the Node.js application running.

------------------------------------------------------------------------

# 🟢 STEP 7 --- Install Ruby

CodeDeploy Agent requires Ruby.

``` bash
sudo apt install ruby-full -y
```

Check:

``` bash
ruby --version
```

------------------------------------------------------------------------

# 🟢 STEP 8 --- Install CodeDeploy Agent

The example below uses the Mumbai (`ap-south-1`) region.

``` bash
cd /home/ubuntu
```

Download the agent installer:

``` bash
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
```

Make it executable:

``` bash
chmod +x install
```

Install:

``` bash
sudo ./install auto
```

Start:

``` bash
sudo systemctl start codedeploy-agent
```

Enable at boot:

``` bash
sudo systemctl enable codedeploy-agent
```

Check:

``` bash
sudo systemctl status codedeploy-agent
```

Expected:

``` text
Active: active (running)
```

------------------------------------------------------------------------

# 🟢 STEP 9 --- Create EC2 IAM Role

Go to:

``` text
AWS Console
→ IAM
→ Roles
→ Create role
```

## Trusted entity

``` text
AWS service
```

## Use case

``` text
EC2
```

## Role name

``` text
EC2-CodeDeploy-Role
```

Attach the required CodeDeploy EC2 permissions.

For a simple learning setup, the AWS managed policy commonly used is:

``` text
AmazonEC2RoleforAWSCodeDeploy
```

Create the role.

------------------------------------------------------------------------

# 🟢 STEP 10 --- Attach IAM Role to EC2

Go:

``` text
EC2
→ Instances
→ Select EC2
→ Actions
→ Security
→ Modify IAM role
```

Select:

``` text
EC2-CodeDeploy-Role
```

Save.

# 🟢 STEP 11 --- Install Nginx

``` bash
sudo apt install nginx -y
```

Start:

``` bash
sudo systemctl start nginx
```

Enable:

``` bash
sudo systemctl enable nginx
```

Check:

``` bash
sudo systemctl status nginx
```

------------------------------------------------------------------------

# 🟢 STEP 12 --- Configure Nginx

Open:

``` bash
sudo nano /etc/nginx/sites-available/default
```

Use:

``` nginx
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:3000;

        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Test:

``` bash
sudo nginx -t
```

Expected:

``` text
syntax is ok
test is successful
```

Restart:

``` bash
sudo systemctl restart nginx
```

------------------------------------------------------------------------

# 🟢 STEP 13 --- Create CodeDeploy Service IAM Role

This is the **second IAM role**.

Go:

``` text
IAM
→ Roles
→ Create role
```

## Trusted entity

``` text
AWS service
```

## Use case

``` text
CodeDeploy
```

## Role name

``` text
CodeDeploy-Service-Role
```

Attach:

``` text
AWSCodeDeployRole
```

Create the role.

------------------------------------------------------------------------

# 🟢 STEP 14 --- Tag EC2

Tag the EC2 instance.

Example:

``` text
Key: Environment
Value: dev
```

So:

``` text
Environment = dev
```

This tag can be used by CodeDeploy to identify the target EC2 instance.

------------------------------------------------------------------------

# 🟢 STEP 15 --- Create CodeDeploy Application

Go:

``` text
AWS Console
→ CodeDeploy
→ Applications
→ Create application
```

## Application name

``` text
node-hello-app
```

## Compute platform

``` text
EC2/On-premises
```

Create application.

------------------------------------------------------------------------

# 🟢 STEP 16 --- Create CodeDeploy Deployment Group

Inside:

``` text
node-hello-app
```

Choose:

``` text
Create deployment group
```

## Deployment group name

``` text
node-hello-app-dg
```

## Service role

Select:

``` text
CodeDeploy-Service-Role
```

## Environment

Select:

``` text
Amazon EC2 instances
```

## Target instances

Use EC2 tags.

Example:

``` text
Key: Environment
Value: dev
```

This selects the EC2 instance with:

``` text
Environment = dev
```

## Deployment configuration

For the simple setup:

``` text
CodeDeployDefault.AllAtOnce
```

Create the deployment group.

------------------------------------------------------------------------

# 🟢 STEP 17 --- Create CodePipeline

Go:

``` text
AWS Console
→ CodePipeline
→ Create pipeline
```

## Pipeline name

``` text
node-app-pipeline
```

------------------------------------------------------------------------

# 🟢 STEP 18 --- CodePipeline Execution Mode

Select:

``` text
Queued
```

------------------------------------------------------------------------

# 🟢 STEP 19 --- CodePipeline Service Role

Select:

``` text
New service role
```

Example generated role:

``` text
AWSCodePipelineServiceRole-ap-south-1-node-app-pipeline
```

Keep:

``` text
Allow AWS CodePipeline to create a service role
```

checked.

This role is for **CodePipeline itself**.

------------------------------------------------------------------------

# 🟢 STEP 20 --- Add GitHub Source

For the source provider choose:

``` text
GitHub via CodeConnections / GitHub App
```

Choose:

``` text
Connect to GitHub
```

## Connection name

``` text
github-connection
```

Choose:

``` text
Install a new app
```

GitHub will open.

Select:

``` text
Only select repositories
```

Select:

``` text
node-hello-app
```

Install/authorize the GitHub App.

Return to AWS and select the installation.

------------------------------------------------------------------------

# 🟢 STEP 21 --- Select GitHub Repository

Select:

``` text
Repository:
YOUR_USERNAME/node-hello-app
```

Branch:

``` text
main
```

Use `master` only if your actual GitHub repository branch is `master`.

------------------------------------------------------------------------

# 🟢 STEP 30 --- Source Artifact Format

Select:

``` text
CodePipeline default
```

Do NOT select:

``` text
Full clone
```

For this simple CodeDeploy deployment, the default ZIP artifact is
sufficient.

------------------------------------------------------------------------

# 🟢 STEP 31 --- Automatic Trigger

Keep:

``` text
Enable automatic trigger / webhook
```

enabled.

For the GitHub source:

``` text
Start your pipeline on push events
```

should be enabled.

The desired behavior is:

``` text
git push
   ↓
GitHub webhook
   ↓
CodePipeline
```

No manual pipeline start is required.

------------------------------------------------------------------------

# 🟢 STEP 32 --- Build Stage

For this project:

``` text
Skip build stage
```

Why?

Because dependency installation is performed on EC2 by:

``` text
scripts/install.sh
```

which runs:

``` bash
npm install
```

Therefore the simple pipeline is:

``` text
GitHub
   ↓
CodePipeline
   ↓
CodeDeploy
   ↓
EC2
```

A CodeBuild stage can be added later for:

-   npm build
-   unit tests
-   linting
-   security scanning
-   artifact creation

------------------------------------------------------------------------

# 🟢 STEP 33 --- Test Stage

For this basic project:

``` text
Skip test stage
```

Tests can be added later.

------------------------------------------------------------------------

# 🟢 STEP 34 --- Deploy Stage

Select:

``` text
Deploy provider:
AWS CodeDeploy
```

Region:

``` text
Asia Pacific (Mumbai)
```

Input artifact:

``` text
SourceArtifact
```

Application name:

``` text
node-hello-app
```

Deployment group:

``` text
node-hello-app-dg
```

Enable:

``` text
Configure automatic rollback on stage failure
```

Keep it enabled.

------------------------------------------------------------------------

# 🟢 STEP 35 --- Create Pipeline

Review the configuration.

Expected:

``` text
Source:
GitHub private repository
        ↓
Build:
Skipped
        ↓
Deploy:
AWS CodeDeploy
        ↓
Application:
node-hello-app
        ↓
Deployment Group:
node-hello-app-dg
        ↓
EC2
```

Click:

``` text
Create pipeline
```

------------------------------------------------------------------------
