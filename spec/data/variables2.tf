variable "alb_is_internal" {
  description = "Boolean determining if the ALB is internal or externally facing."
  default     = false
}

variable "alb_name" {
  description = "The name of the ALB as will show in the AWS EC2 ELB console."
}

variable "alb_protocols" {
  description = "The protocols the ALB accepts. e.g.: [\"HTTP\"]"
  type        = "list"
  default     = ["HTTP"]
}

variable "alb_security_groups" {
  description = "The security groups with which we associate the ALB. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"
  type        = "list"
}

variable "region" {
  description = "AWS region to use."
}

variable "backend_port" {
  description = "The port the service on the EC2 instances listen on."
  default     = 80
}

# hello there
/* whats up
  doolly
*/
resource "aws_instance" "web" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"

  tags {
    Name = "HelloWorld"
  }
}

# A computed default name prefix
locals {
  default_name_prefix = "${var.project_name}-web"
  name_prefix         = "${var.name_prefix != "" ? var.name_prefix : local.default_name_prefix}"
  octal_test = 04453
  hex_test = 0xAABBCC
  scientific_test = 9.8e10
}

provider "aws" {
  access_key = "foo"
  secret_key = "bar"
  region     = "us-east-1"
}

output "addresses" {
  value = ["${aws_instance.web.*.public_dns}"]
}

data "aws_ami" "web" {
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:Component"
    values = ["web"]
  }

  most_recent = true
}

terraform {
  required_version = "> 0.7.0"
}

