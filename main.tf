# -----------------------------------------------
# main.tf — EC2 with Apache2 Installation Script
# -----------------------------------------------

# Fetch existing project-vpc
data "aws_vpc" "project_vpc" {
  filter {
    name   = "tag:Name"
    values = ["project-vpc"]
  }
}

# Fetch existing public subnet
data "aws_subnet" "public" {
  filter {
    name   = "tag:Name"
    values = ["project-subnet-public1-us-east-2a"]
  }
}

# Fetch latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group — allow SSH, HTTP
resource "aws_security_group" "ec2_sg" {
  name        = "apache-ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.project_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "apache-ec2-sg"
    ManagedBy = "Terraform"
  }
}

# EC2 Instance with Apache2 install script
resource "aws_instance" "apache_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name != "" ? var.key_name : null

  # Task 2 & 3 — Apache2 install script runs on launch
  user_data = <<-EOF
    #!/bin/bash
    # Update packages
    yum update -y

    # Install Apache (httpd on Amazon Linux)
    yum install -y httpd

    # Start and enable Apache
    systemctl start httpd
    systemctl enable httpd

    # Create a simple webpage showing the instance IP
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/public-ipv4)

    echo "<h1>Apache is Running!</h1><p>Instance IP: $PUBLIC_IP</p>" \
      > /var/www/html/index.html
  EOF

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name      = "apache-ec2"
    ManagedBy = "Terraform"
  }
}

# Task 4 — Save Public IP to a local file
resource "local_file" "ip_output" {
  content  = "EC2 Public IP: ${aws_instance.apache_ec2.public_ip}\n"
  filename = "${path.module}/ec2_ip_address.txt"
}
