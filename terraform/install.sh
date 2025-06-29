#!/bin/bash

# Update system packages
sudo yum update -y

# Install yum-utils
sudo yum install -y yum-utils

# Add HashiCorp repository
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

# Install Terraform
sudo yum install -y terraform

# Verify installation
terraform -v
