provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "skmt_key_pair" {
  key_name   = "skmt_key_pair"
  public_key = tls_private_key.ssh_key.public_key_openssh
}


resource "aws_instance" "skmt-ec2-instance" {
  ami           = "ami-0c94855ba95c71c99"  # Example Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"
  subnet_id              = aws_subnet.skmt_private_subnet.id
  vpc_security_group_ids = [aws_security_group.skmt_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = false
  key_name = "skmt_aws5_keypair_us_east_1"
  
  tags = {
    Name = "skmt-ec2-instance"
  }
  
  user_data = <<-EOF
          #!/bin/bash
          # Update system packages
          sudo yum update -y
          
          # Install dependencies
          sudo yum install -y curl wget conntrack

          #   yum install -y amazon-ssm-agent
          #   systemctl enable amazon-ssm-agent
          #   systemctl start amazon-ssm-agent
          # fi

          # # Install Docker
          # sudo amazon-linux-extras install docker -y
          # sudo systemctl enable docker
          # sudo systemctl start docker

          # # Install Minikube
          # curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
          # sudo install minikube-linux-amd64 /usr/local/bin/minikube

          # # Install kubectl
          # curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
          # sudo install kubectl /usr/local/bin/kubectl

          # # Enable docker for the ec2-user
          # sudo usermod -aG docker ec2-user

          # # Start Minikube (optional, will need --driver=none for EC2 VM)
          # # minikube start --driver=none
          EOF
}