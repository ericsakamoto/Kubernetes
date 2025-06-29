provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "skmt-ec2-instance" {
  ami           = "ami-0c94855ba95c71c99"  # Example Amazon Linux 2 AMI in us-east-1
  instance_type = "t3.xlarge"
  subnet_id              = aws_subnet.skmt_private_subnet.id
  vpc_security_group_ids = [aws_security_group.skmt_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = true
  key_name = "skmt_aws5_keypair_us_east_1"
  
  tags = {
    Name = "skmt-ec2-instance"
  }
  
  user_data = <<-EOF
          #!/bin/bash

          # Update system packages
          sudo yum update -y

          # Install dependencies
          sudo yum install -y curl wget git unzip bash-completion conntrack socat

          # Install Docker
          sudo amazon-linux-extras enable docker
          sudo yum install -y docker
          sudo systemctl start docker
          sudo systemctl enable docker

          # Add ec2-user to docker group
          sudo usermod -aG docker ec2-user
          newgrp docker

          # Install kubectl
          curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
          chmod +x kubectl
          sudo mv kubectl /usr/local/bin/

          # Enable kubectl bash completion
          echo "source <(kubectl completion bash)" >> ~/.bashrc
          echo "alias k=kubectl" >> ~/.bashrc
          echo "complete -F __start_kubectl k" >> ~/.bashrc

          # Install Minikube
          curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
          sudo install minikube-linux-amd64 /usr/local/bin/minikube

          # Start Minikube using Docker driver
          minikube start --driver=docker

          # Install git
          sudo yum install -y git

          # Clone the kubectx repository
          git clone https://github.com/ahmetb/kubectx.git ~/.kubectx

          # Add binaries to your PATH
          sudo ln -s ~/.kubectx/kubectx /usr/local/bin/kubectx
          sudo ln -s ~/.kubectx/kubens /usr/local/bin/kubens

          # Optional: Enable bash completion
          mkdir -p ~/.bash_completion.d
          ln -s ~/.kubectx/completion/kubens.bash ~/.bash_completion.d/kubens
          ln -s ~/.kubectx/completion/kubectx.bash ~/.bash_completion.d/kubectx
          echo 'source ~/.bash_completion.d/kubectx' >> ~/.bashrc
          echo 'source ~/.bash_completion.d/kubens' >> ~/.bashrc

          # Apply changes to current shell
          source ~/.bashrc

          # Download the latest release (Linux AMD64 binary)
          curl -Lo k9s.tar.gz https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz

          # Extract the binary
          tar -xzf k9s.tar.gz

          # Move to a directory in your PATH
          sudo mv k9s /usr/local/bin/

          # Clean up
          rm k9s.tar.gz

          EOF
}