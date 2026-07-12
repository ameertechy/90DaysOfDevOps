terraform {
  required_version = ">=1.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "my-first" {
  bucket = "terraweek-ameerul-day1-8f3a2"

  tags = {
    Name        = "Terraweek"
    Environment = "Terraform"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # free-tier eligible

  tags = {
    Name      = "terraweek-day1"
    Project   = "TerraWeek"
    ManagedBy = "Terraform"
  }
}