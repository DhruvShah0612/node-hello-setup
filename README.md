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
   │ Source Artifact
   ▼
S3 Artifact Store
   │
   ▼
AWS CodeDeploy
   │
   │ Deployment
   ▼
EC2 Ubuntu
   │
   ├── CodeDeploy Agent
   ├── Node.js
   ├── PM2
   └── Nginx
          │
          ▼
      Node.js App
        :3000
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
t2.micro
```

or another appropriate/free-tier-eligible instance type available in
your account.

### Key Pair

Create/select:

``` text
node-app-key
```

Download the `.pem` file.

------------------------------------------------------------------------

# 🟢 STEP 2 --- EC2 Security Group

Configure inbound rules.

## For testing

  Type           Port Source
  ------------ ------ -----------
  SSH              22 Your IP
  HTTP             80 0.0.0.0/0
  Custom TCP     3000 Your IP

## Recommended final setup with Nginx

  Type      Port Source
  ------- ------ -----------
  SSH         22 Your IP
  HTTP        80 0.0.0.0/0
  HTTPS      443 0.0.0.0/0

Port `3000` does not need to be public when Nginx is used as the reverse
proxy.

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

# 🧠 IAM Roles Explained

There are two important roles.

## Role 1 --- EC2 role

``` text
EC2-CodeDeploy-Role
```

Used by:

``` text
EC2 / CodeDeploy Agent
```

## Role 2 --- CodeDeploy service role

``` text
CodeDeploy-Service-Role
```

Used by:

``` text
AWS CodeDeploy service
```

Remember:

``` text
EC2-CodeDeploy-Role
       ↓
EC2

CodeDeploy-Service-Role
       ↓
CodeDeploy
```

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
Superseded
```

### Meaning

If a new commit arrives while an old execution is running, the newer
execution gets priority and the old execution can be superseded.

For a single EC2 deployment this is a useful option.

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

# 🟢 STEP 36 --- First Deployment

CodePipeline should execute:

``` text
Source      → Succeeded
Build       → Skipped
Deploy      → Succeeded
```

If successful, CodeDeploy deploys the files to:

``` text
/var/www/html
```

------------------------------------------------------------------------

# 🟢 STEP 37 --- Verify Deployment on EC2

SSH into EC2:

``` bash
ssh -i node-app-key.pem ubuntu@EC2_PUBLIC_IP
```

Go to deployment directory:

``` bash
cd /var/www/html
```

Check:

``` bash
ls -la
```

Expected:

``` text
index.js
package.json
package-lock.json
appspec.yml
scripts/
```

------------------------------------------------------------------------

# 🟢 STEP 38 --- Check PM2

``` bash
pm2 status
```

Expected:

``` text
node-app    online
```

Check logs:

``` bash
pm2 logs node-app
```

------------------------------------------------------------------------

# 🟢 STEP 39 --- Test Node.js Directly

``` bash
curl http://localhost:3000
```

Expected:

``` text
Hello from Node.js AWS CodeDeploy 🚀
```

------------------------------------------------------------------------

# 🟢 STEP 40 --- Test Nginx

``` bash
curl http://localhost
```

Expected:

``` text
Hello from Node.js AWS CodeDeploy 🚀
```

------------------------------------------------------------------------

# 🟢 STEP 41 --- Browser Test

Open:

``` text
http://EC2_PUBLIC_IP
```

The Node.js application should be displayed.

Because Nginx is being used, the public request is:

``` text
Browser
   ↓
Port 80
   ↓
Nginx
   ↓
127.0.0.1:3000
   ↓
Node.js
```

------------------------------------------------------------------------

# 🔥 STEP 42 --- Test Automatic Deployment

Change your application locally.

Example:

``` javascript
app.get("/", (req, res) => {
    res.send("Version 2 - Auto Deployment 🚀");
});
```

Commit:

``` bash
git add .
```

``` bash
git commit -m "update application"
```

Push:

``` bash
git push origin main
```

Now do NOT manually start CodePipeline.

The automatic flow should be:

``` text
git push
   ↓
GitHub
   ↓
Webhook
   ↓
CodePipeline
   ↓
Source
   ↓
CodeDeploy
   ↓
EC2
   ↓
Files updated
   ↓
npm install
   ↓
PM2 restart
   ↓
New version LIVE
```

Refresh the browser.

Expected:

``` text
Version 2 - Auto Deployment 🚀
```

------------------------------------------------------------------------

# 🔥 STEP 43 --- What Happens During CodeDeploy?

CodeDeploy receives the source artifact.

### 1. Download

CodeDeploy downloads the pipeline artifact to EC2.

### 2. Files

AppSpec tells CodeDeploy:

``` yaml
files:
  - source: /
    destination: /var/www/html
```

Therefore files are deployed to:

``` text
/var/www/html
```

### 3. AfterInstall

CodeDeploy executes:

``` text
scripts/install.sh
```

which runs:

``` bash
npm install
```

### 4. ApplicationStart

CodeDeploy executes:

``` text
scripts/start.sh
```

which runs:

``` bash
pm2 delete node-app || true
pm2 start index.js --name node-app
pm2 save
```

### 5. Application is live

``` text
PM2
 ↓
Node.js :3000
 ↓
Nginx :80
 ↓
Browser
```

------------------------------------------------------------------------

# 🟢 STEP 44 --- CodeDeploy Agent Troubleshooting

Check status:

``` bash
sudo systemctl status codedeploy-agent
```

Expected:

``` text
Active: active (running)
```

Restart:

``` bash
sudo systemctl restart codedeploy-agent
```

Check log:

``` bash
sudo tail -100 /var/log/aws/codedeploy-agent/codedeploy-agent.log
```

Live log:

``` bash
sudo tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log
```

Check systemd logs:

``` bash
sudo journalctl -u codedeploy-agent --no-pager -n 100
```

------------------------------------------------------------------------

# 🟢 STEP 45 --- CodeDeploy Connectivity Test

The EC2 instance needs network connectivity to AWS services.

Test CodeDeploy:

``` bash
curl -I https://codedeploy.ap-south-1.amazonaws.com
```

Test S3:

``` bash
curl -I https://s3.ap-south-1.amazonaws.com
```

Make sure outbound HTTPS traffic on port `443` is allowed.

------------------------------------------------------------------------

# 🟢 STEP 46 --- PM2 Troubleshooting

Check:

``` bash
pm2 status
```

Logs:

``` bash
pm2 logs node-app
```

Restart manually for testing:

``` bash
pm2 restart node-app
```

Check Node:

``` bash
node -v
```

Check npm:

``` bash
npm -v
```

Check PM2:

``` bash
pm2 -v
```

------------------------------------------------------------------------

# 🟢 STEP 47 --- Nginx Troubleshooting

Test configuration:

``` bash
sudo nginx -t
```

Restart:

``` bash
sudo systemctl restart nginx
```

Status:

``` bash
sudo systemctl status nginx
```

Check Nginx error log:

``` bash
sudo tail -100 /var/log/nginx/error.log
```

------------------------------------------------------------------------

# 🔴 Common Problems

## 1. CodeDeploy Agent Not Running

Check:

``` bash
sudo systemctl status codedeploy-agent
```

Fix:

``` bash
sudo systemctl restart codedeploy-agent
```

------------------------------------------------------------------------

## 2. `npm: command not found`

Check:

``` bash
which node
which npm
node -v
npm -v
```

Make sure Node.js is installed on EC2.

------------------------------------------------------------------------

## 3. `pm2: command not found`

Install:

``` bash
sudo npm install -g pm2
```

Check:

``` bash
pm2 -v
```

------------------------------------------------------------------------

## 4. Permission Denied

Check:

``` bash
ls -la /var/www/html
```

Fix ownership if required:

``` bash
sudo chown -R ubuntu:ubuntu /var/www/html
```

------------------------------------------------------------------------

## 5. Nginx 502 Bad Gateway

Check Node:

``` bash
pm2 status
```

Then:

``` bash
curl http://localhost:3000
```

If this fails, the problem is with Node.js/PM2.

If this works, check Nginx:

``` bash
sudo nginx -t
```

------------------------------------------------------------------------

## 6. CodePipeline Does Not Trigger

Check:

``` text
GitHub
   ↓
CodeConnections
   ↓
Webhook / automatic trigger
```

Make sure:

-   Correct repository is selected
-   Correct branch is selected
-   GitHub connection is healthy
-   Automatic trigger is enabled
-   Push is being made to the configured branch

Example:

``` bash
git push origin main
```

------------------------------------------------------------------------

# 🔐 IAM Role Summary

This project uses multiple IAM roles.

  -----------------------------------------------------------------------------------------------------------
  Role                                                        Used By                 Purpose
  ----------------------------------------------------------- ----------------------- -----------------------
  `EC2-CodeDeploy-Role`                                       EC2                     Allows EC2/CodeDeploy
                                                                                      Agent to access
                                                                                      required AWS resources

  `CodeDeploy-Service-Role`                                   CodeDeploy              Allows CodeDeploy
                                                                                      service to perform
                                                                                      deployments

  `AWSCodePipelineServiceRole-ap-south-1-node-app-pipeline`   CodePipeline            Allows CodePipeline to
                                                                                      access required AWS
                                                                                      resources
  -----------------------------------------------------------------------------------------------------------

Do not confuse these roles.

``` text
EC2
 ↓
EC2-CodeDeploy-Role

CodeDeploy
 ↓
CodeDeploy-Service-Role

CodePipeline
 ↓
AWSCodePipelineServiceRole-...
```

------------------------------------------------------------------------

# 📦 Artifact Explanation

## Source Artifact

The GitHub source is collected by CodePipeline.

``` text
GitHub
   ↓
Source Stage
   ↓
SourceArtifact
```

The source artifact contains the project files required by the next
stage.

## S3 Artifact Store

CodePipeline uses an S3 bucket as its artifact store.

Conceptually:

``` text
GitHub
   ↓
CodePipeline
   ↓
S3 Artifact Store
   ↓
CodeDeploy
```

You normally do not need to manually upload the artifact to S3 for this
pipeline.

------------------------------------------------------------------------

# 🔥 Complete Final Architecture

``` text
                         DEVELOPER
                             │
                             │ git push
                             ▼
                  ┌─────────────────────┐
                  │ GitHub Private Repo │
                  │                     │
                  │ index.js            │
                  │ package.json        │
                  │ appspec.yml         │
                  │ scripts/            │
                  └──────────┬──────────┘
                             │
                             │ GitHub Connection
                             │ Webhook
                             ▼
                  ┌─────────────────────┐
                  │    CodePipeline     │
                  │                     │
                  │ Source              │
                  │ Build - Skipped     │
                  │ Deploy              │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │   S3 Artifact Store │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │     CodeDeploy      │
                  │                     │
                  │ App: node-hello-app │
                  │ Group: node-hello-  │
                  │       app-dg        │
                  └──────────┬──────────┘
                             │
                             ▼
              ┌──────────────────────────────┐
              │         EC2 Ubuntu           │
              │                              │
              │  CodeDeploy Agent            │
              │       ↓                      │
              │  /var/www/html               │
              │       ↓                      │
              │  npm install                 │
              │       ↓                      │
              │  PM2                         │
              │       ↓                      │
              │  Node.js :3000               │
              │       ↑                      │
              │  Nginx :80                   │
              └──────────────┬───────────────┘
                             │
                             ▼
                          Browser
```

------------------------------------------------------------------------

# 🧠 One-Line Explanation of Every Service

``` text
GitHub       = Code store
CodePipeline = Automation / CI-CD flow
S3           = Pipeline artifact storage
CodeDeploy   = EC2 deployment
EC2          = Server
CodeDeploy Agent = EC2 deployment listener
IAM          = Permissions
PM2          = Node.js process manager
Nginx        = Reverse proxy
Node.js      = Application
```

------------------------------------------------------------------------

# ✅ Final Checklist

Before considering the project complete, verify:

``` text
☑ GitHub private repository created
☑ index.js created
☑ package.json created
☑ package-lock.json created
☑ appspec.yml created
☑ install.sh created
☑ start.sh created
☑ chmod +x scripts/*.sh done
☑ GitHub code pushed
☑ Ubuntu EC2 launched
☑ Security Group configured
☑ Node.js installed
☑ npm installed
☑ PM2 installed
☑ Ruby installed
☑ CodeDeploy Agent installed
☑ CodeDeploy Agent running
☑ EC2-CodeDeploy-Role created
☑ EC2 role attached to EC2
☑ Nginx installed
☑ Nginx configured
☑ CodeDeploy-Service-Role created
☑ EC2 tagged
☑ CodeDeploy application created
☑ CodeDeploy deployment group created
☑ CodePipeline service role created
☑ GitHub connection created
☑ Private repository connected
☑ Correct branch selected
☑ CodePipeline default artifact selected
☑ Automatic webhook enabled
☑ Build stage skipped
☑ Test stage skipped
☑ CodeDeploy deploy stage configured
☑ First deployment successful
☑ Browser test successful
☑ Automatic deployment tested
```

# 🎯 Final Result

After the complete setup, the developer only needs to do:

``` bash
git add .
git commit -m "update application"
git push origin main
```

Everything else is automatic:

``` text
GitHub
  ↓
Webhook
  ↓
CodePipeline
  ↓
Source Artifact
  ↓
CodeDeploy
  ↓
EC2
  ↓
npm install
  ↓
PM2 restart
  ↓
Nginx
  ↓
LIVE 🚀
```
