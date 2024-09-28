#!/bin/bash

#Update the package list
sudo apt update -y

#Install Git if not already installed
sudo apt install -y git

#Navigate to the directory where you want to clone the repository
cd ~

#Clone the repository from GitHub
git clone https://github.com/joesghub/microblog_VPC_deployment.git microblog_VPC_deployment

#Change directory into the cloned repository
cd microblog_VPC_deployment

#Add Python PPA for Python 3.9 and install Python
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update -y

#Install Python 3.9, Python 3.9 venv, pip, and nginx
sudo apt install -y python3.9 python3.9-venv python3-pip nginx

#Clone your GH repository to the server, cd into the directory, create and activate a python virtual environment with
python3.9 -m venv venv
source venv/bin/activate

#While in the python virtual environment, install the application dependencies and other packages by running
pip install -r requirements.txt
pip install pytest
pip install gunicorn pymysql cryptography

#Set the ENVIRONMENTAL Variable
#This command sets the environment variable FLASK_APP to microblog.py, which tells Flask which Python file to use as the main application. 
#It prepares Flask to run commands that depend on the app.
FLASK_APP=microblog.py

#Compiles translations and upgrades the database
flask translate compile
flask db upgrade

#Run the following command and then put the servers public IP address into the browser address bar
gunicorn -b :5000 -w 4 microblog:app 
