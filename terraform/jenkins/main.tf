terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = merge(var.tags, {
      Project   = "pipeline-demo"
      Component = "jenkins"
      ManagedBy = "terraform"
    })
  }
}

variable "aws_region" {
  description = "AWS region for the Jenkins controller."
  type        = string
  default     = "us-west-2"
}

variable "aws_profile" {
  description = "Local AWS CLI profile used for demo deployments."
  type        = string
  default     = "default"
}

variable "name" {
  description = "Name tag for the Jenkins instance."
  type        = string
  default     = "pipeline-demo-jenkins"
}

variable "ami" {
  description = "AMI ID for the Jenkins instance."
  type        = string
  default     = "ami-08d70e59c07c61a3a"
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 key pair name."
  type        = string
  default     = "baxter-devops"
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to reach SSH."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "jenkins_cidr_blocks" {
  description = "CIDR blocks allowed to reach the Jenkins UI."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional resource tags."
  type        = map(string)
  default     = {}
}

resource "aws_security_group" "jenkins" {
  name        = "${var.name}-sg"
  description = "Jenkins controller ingress"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.jenkins_cidr_blocks
  }

  egress {
    description = "Outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = var.name
  }
}

output "jenkins_public_ip" {
  description = "Public IP address for the Jenkins controller."
  value       = aws_instance.jenkins.public_ip
}
