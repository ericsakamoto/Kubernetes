terraform {
  required_version = ">= 1.11.0"
  
  backend "s3" {
    bucket         = "skmt-aws5-bucket"
    key            = "skmt-ec2-instance/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}