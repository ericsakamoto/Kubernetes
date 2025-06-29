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
          set -euxo pipefail

          # Install base dependencies
          yum install -y curl wget unzip git bash-completion

          # Install k3s (includes kubectl and containerd)
          curl -sfL https://get.k3s.io | sh -

          # Wait for k3s to start
          sleep 10

          # Set up kubectl for ec2-user
          mkdir -p /home/ec2-user/.kube
          cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
          chown -R ec2-user:ec2-user /home/ec2-user/.kube
          sed -i 's/127.0.0.1/localhost/' /home/ec2-user/.kube/config

          # Add kubectl alias for ec2-user
          echo "alias kubectl='/usr/local/bin/kubectl'" >> /home/ec2-user/.bashrc

          # Install kubectx and kubens
          KUBECTX_DIR="/opt/kubectx"
          git clone https://github.com/ahmetb/kubectx.git "$KUBECTX_DIR"
          ln -s "$KUBECTX_DIR/kubectx" /usr/local/bin/kubectx
          ln -s "$KUBECTX_DIR/kubens" /usr/local/bin/kubens
          chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens

          # Optional: enable bash completion for kubectl, kubectx, and kubens
          /usr/local/bin/kubectl completion bash > /etc/bash_completion.d/kubectl
          "$KUBECTX_DIR"/completion/kubectx.bash > /etc/bash_completion.d/kubectx
          "$KUBECTX_DIR"/completion/kubens.bash > /etc/bash_completion.d/kubens

          # Set ownership for ec2-user access
          chown -R ec2-user:ec2-user "$KUBECTX_DIR"

          # Pre-load context and node info
          /usr/local/bin/kubectl get nodes
          EOF
}