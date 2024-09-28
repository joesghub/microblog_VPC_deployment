#!/bin/bash

# Define variables
APP_SERVER_IP="10.0.18.201" #private ip
WEB_SERVER_IP=" "
APP_SSH_KEY="/home/ubuntu/keys/microblog_app_server.pem" #on web server
JENKINS_SSH_KEY="home/ubuntu/.ssh/jenkins_key"
REMOTE_USER="ubuntu"
REMOTE_SCRIPT="start_app.sh"
RAW_REMOTE="https://raw.githubusercontent.com/joesghub/microblog_VPC_deployment/refs/heads/main/scripts/start_app.sh"
LOCAL_SCRIPT_DIR="/home/ubuntu/jenkins_server_scripts"
LOCAL_SCRIPT_PATH="/home/ubuntu/jenkins_server_scripts/start_app.sh"
SCRIPT_DIR="/home/ubuntu/app_server_scripts"



#SSH into Web server from Jenkins server
echo "Connecting to Web Server at $WEB_SERVER_IP from Jenkins Server..."
ssh -i $JENKINS_SSH_KEY $REMOTE_USER@$WEB_SERVER_IP

#Copy start_app.sh to the Web Server from Jenkins Server
echo "Copying to Start Application script to Web Server from Jenkins Server..."
mkdir -p $LOCAL_SCRIPT_DIR
curl -o $LOCAL_SCRIPT_PATH $RAW_REMOTE
chmod +x $LOCAL_SCRIPT_PATH

#Ensure the script directory exists on Application server
echo "Checking if script directory exists in Application Server from the Web Server..."
ssh -i $APP_SSH_KEY $REMOTE_USER@$APP_SERVER_IP "mkdir -p $SCRIPT_DIR"

#Copying start_app.sh to the Application Server from the Web Server
echo "Copying $LOCAL_SCRIPT_PATH to Application Server at $APP_SERVER_IP..."
scp -i $APP_SSH_KEY $LOCAL_SCRIPT_PATH $REMOTE_USER@$APP_SERVER_IP:$SCRIPT_DIR

#SSH into the Application Server and run start_app.sh
echo "Connecting to Application Server at $APP_SERVER_IP and running $REMOTE_SCRIPT..."

#&& between commands to ensure the next command only runs if the previous one succeeds (safer execution).
#explicitly invoking bash -c 'source ...' ensures you're using bash 
#even if the default shell on the remote server is something else (e.g., sh or dash).
ssh -i $SSH_KEY $REMOTE_USER@$APP_SERVER_IP "
    cd $SCRIPT_DIR &&
    chmod +x $REMOTE_SCRIPT &&
    bash -c 'source ./$REMOTE_SCRIPT'
"

# Confirm the script execution
if [ $? -eq 0 ]; then
    echo "Application started successfully on the Application Server."
else
    echo "Failed to start the application on the Application Server."
fi
