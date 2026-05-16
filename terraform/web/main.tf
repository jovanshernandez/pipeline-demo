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
      Component = "web"
      ManagedBy = "terraform"
    })
  }
}

variable "aws_region" {
  description = "AWS region for the web host."
  type        = string
  default     = "us-west-2"
}

variable "aws_profile" {
  description = "Local AWS CLI profile used for demo deployments."
  type        = string
  default     = "default"
}

variable "name" {
  description = "Name tag for the web instance."
  type        = string
  default     = "pipeline-demo-web"
}

variable "ami" {
  description = "AMI ID for the web instance."
  type        = string
  default     = "ami-08d70e59c07c61a3a"
}

variable "instance_type" {
  description = "EC2 instance type for the web host."
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

variable "web_cidr_blocks" {
  description = "CIDR blocks allowed to reach the web application."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional resource tags."
  type        = map(string)
  default     = {}
}

resource "aws_security_group" "web" {
  name        = "${var.name}-sg"
  description = "Web host ingress"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  ingress {
    description = "Application"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = var.web_cidr_blocks
  }

  egress {
    description = "Outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = var.name
  }
}

output "web_public_ip" {
  description = "Public IP address for the web host."
  value       = aws_instance.web.public_ip
}
