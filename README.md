󠀦󠀦Image pipeline Architecture
---

⏺️ Setup Slack and local workstation
Create Slack workspace and channel
To use the pipeline-chatbot-slack module in this project, a Slack workspace ID and channel ID are required. Follow the steps below:
First, create a slack Workspace.
- Go to, https://slack.com/get-started#/createnew.
- Enter your email address and click Continue
- Check your email for a confirmation code.
- Enter your code and click Create a Workspace 
- Follow the prompts and the workspace will be fully created.

How to Create a Slack WorkspaceNext, create a private slack channel and note the channel ID
- From your slack sidebar, click the + icon next to Channels
- Select Create a channel and provide a channel name
- Provide a description and choose a channel type of private
- Optionally, invite another member by email or skip for now
- Right-click on the channel name in the left pane, and choose Copy Link
- 🚨 The channel ID is the 9-character string at the end of the URL. 
- Or obtain the Channel ID in the About tab of the channel settings.
- Run the /invite @AWS command in Slack to invite the AWS Chatbot to the chat room.
Slack Channel ID for the 'pipeline-chatbot-slack' module

---

Authorize AWS Chatbot in Slack Workspace
To get the workspace ID, you must perform an initial authorization flow with Slack in the AWS Chatbot console. Then you can copy the workspace ID from the console. The authorization steps are summarized below.
On the left navigation pane in Slack, choose Apps
- Browse the directory for the AWS Chatbot app
- Choose, Add to add AWS Chatbot to your workspace
- Next, Open the AWS Chatbot console
- Under Configure a chat client, choose Slack -> Configure client
Setup AWS Chatbot with slackFrom the dropdown list at the top right, choose the Slack workspace that you want to use with AWS Chatbot

🚨 Copy the Workspace ID found under Workspace details.
Workspace ID for terraform module

---

Setup SSH connection to AWS CodeCommit Repositories
🚨 To connect to CodeCommit for the first time, you must complete some initial configuration steps. The steps below are for Linux and macOS.
1. Generate a public and private key by running the command below and specify these paths for the private and public key files.
For the private key file: ~/.ssh/codecommit_rsa 
For the public key file: ~/.ssh/codecommit_rsa.pub 
ssh-keygen -t rsa -b 4096
2. Copy the data in the public key file cat ~/.ssh/codecommit_rsa.pub
3. Navigate to AWS IAM Console -> Users -> Select your IAM User name 
- Select Security Credentials -> Upload SSH public key from the step above
- Copy the information in SSH Key ID as shown below
SSH Key ID to connect to CodeCommit4. Add the lines below to your ~/.ssh/config file with your text editor. Create the file if it doesn't exist. Replace the text XXXXXXXXXXXXXXXXXXXX in the second line below with the SSH Key ID from the previous step.
Host git-codecommit.*.amazonaws.com
  User XXXXXXXXXXXXXXXXXXXX
  IdentityFile ~/.ssh/codecommit_rsa
5. Update the permission on the file and validate your SSH configuration.
You should see a message afterward stating "You have successfully authenticated over SSH. You can use Git to interact with AWS CodeCommit….."
chmod 600 "~/.ssh/config" && ssh git-codecommit.us-east-1.amazonaws.com

---

Deploy remote backend resources
The state of resources created from within the pipeline and image pipeline solution separately.
🚀 Run the commands below to create the S3 buckets and DynamoDb table.

git clone https://github.com/yemisprojects/golden-image-pipeline.git
cd "step-1 | setup-remote-backend"
terraform init && terraform validate && terraform apply -auto-approve

You should see 14 resources added. Note down the values of these variables for the next steps; pipeline_s3_bucket_id and main_s3_bucket_id
🎬 Phase 1 completed 👍.

Deploy Image pipeline solution
🚨 First, update the bucket argument value in the backend.conf file. Use the main_s3_bucket_id output value from the screenshot above.

#FILE_NAME: step-2 | Deploy-Infrastructure-TF-mainfests/backend.conf
dynamodb_table = "main-infra-tfstate-lock"           
bucket = "main-infra-tfstate-284700228002"   #<======= main_s3_bucket_id
key    = "main-infra/terraform.tfstate"
region = "us-east-1" 
encrypt = true

Update all argument values in the pipeline.auto.tfvars file accordingly.  Use the slack channel and workspace ID obtained previously.

#FILE_NAME: step-2 | Deploy-Infrastructure-TF-mainfests/pipeline.auto.tfvars
pipeline_approval_email_id = "example@gmail.com"
inspector_email_id         = "example@gmail.com"
slack_channel_id           = "XXXXXXXXXXX"
slack_workspace_id         = "XXXXXXXXXXX"

🚀 Run the commands below to deploy the solution in us-east-1
git clone https://github.com/yemisprojects/golden-image-pipeline.git
cd "step-2 | Deploy-Infrastructure-TF-mainfests"
terraform init -backend-config=backend.conf && terraform apply -auto-approve

Note, you will receive 3 emails from AWS, two to confirm subscriptions to two SNS topics (pipeline-approval and aws-inspector-alerts ) and one to verify your SES email identity to get vulnerability reports. Ensure you click the subscription links to confirm. You should see 47 resources added.
🎬 Phase 2 completed 👍.

Push Files to CodeCommit Repository
I assume you have followed the steps earlier to set up SSH to connect to CodeCommit repositories. Clone the newly created CodeCommit repo.
git clone "ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/golden-ami-repo"

Copy all files within the GitHub folder step-3 | push-to-codecommit to the CodeCommit repo. This must be the directory tree of the golden-ami-repo
➜ tree -L 1 golden-ami-repo
golden-ami-repo
├── buildspec-inspector.yml
├── buildspec-packer.yml
├── buildspec-share_ami.yml
├── packer_manifests
├── scripts
└── terraform_manifests

🚨 In the terraform_manifests/backend.conf file, update the bucket argument value to the output variable value of,pipeline_s3_bucket_id.

dynamodb_table = "ami-pipeline-tfstate-db-lock" 
bucket = "ami-pipeline-tfstate-s3-7754459301"   #<=======pipeline_s3_bucket_id
key    = "ami-pipeline/terraform.tfstate"
region = "us-east-1" 
encrypt = true
#FILE_NAME: golden-ami-repo/terraform_manifests/backend.conf

Add the list of account IDs you will like to share the golden AMIs to the packer_manifests/files/account_list.txt file.
111111111111 
222222222222

Commit all files locally and push changes to the CodeCommit repo.
git add -A && git commit -m "first commit" && git push

🎬 Phase 3 completed 👍

Verify deployment and Shared AMI
After pushing all changes, the pipeline will start execution and transition through all five stages below.

Afterward, you should receive the following:
- An SNS notification for manual approval. Click the link in the email, Click Review on the Manual approval stage, and Click Approve.
- You will also get Slack notifications as the pipeline transitions through some stages. The last notification here shows the pipeline succeeded.
You will also receive an email from AWS SES with an email attached.

Log into the account(s) you shared an AMI with and verify. 
- Navigate to EC2 -> Images -> AMIs -> Private Images
- The AMI will have this name format java-app-*

Awesome job on deploying Image Pipeline Solution 🙌 🎉 .