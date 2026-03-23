#!/bin/bash
# -----------------------------------------------
# apache_install.sh — Apache2 Installation Script
# Task 2: Script to install Apache2
# -----------------------------------------------

# Update all packages
yum update -y

# Install Apache (httpd on Amazon Linux)
yum install -y httpd

# Start Apache service
systemctl start httpd

# Enable Apache to start on boot
systemctl enable httpd

# Get instance public IP from metadata
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

# Create a simple webpage
echo "<h1>Apache is Running!</h1><p>Instance IP: $PUBLIC_IP</p>" \
  > /var/www/html/index.html

# Confirm Apache is running
systemctl status httpd
echo "Apache installed successfully! IP: $PUBLIC_IP"
