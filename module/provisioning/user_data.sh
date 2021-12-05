#!/usr/bin/env bash

# Variables
CODEDEPLOY_BIN="/opt/codedeploy-agent/bin/codedeploy-agent"

# Update yum
sudo yum update -y

# Install pre-reqs for codedeploy
sudo yum install -y ruby
sudo yum install -y wget

# Stop existing version of codedeploy-agent and cleanup
$CODEDEPLOY_BIN stop
sudo yum erase codedeploy-agent -y

# download and install latest code deploy update
cd /home/ec2-user && \
wget https://aws-codedeploy-ap-southeast-2.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
rm install

# Install anisble
sudo amazon-linux-extras install ansible2 -y

# Install nginx
sudo yum install -y nginx

# Enable and start nginx service
sudo chkconfig nginx on
sudo service nginx start