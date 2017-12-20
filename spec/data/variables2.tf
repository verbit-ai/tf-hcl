variable "interpolated_string_var" {
  default = "x"
}
module "simple_module" {
  count = 1
}

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

