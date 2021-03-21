provider "aws" {
    region = "us-west-2"
    profile = "trailmapper-west"
}

variable "name" {
    description = "Name the instance on deploy"
}

resource "aws_instance" "baxter-devops_web" {
    ami = "ami-08d70e59c07c61a3a"
    instance_type = "t2.micro"
    key_name = "baxter-devops"

    tags = {
        Name = "${var.name}"
    }
}