variable "string_var" {
  type = "string"
  # lead comment example 1
  default = "a_string"
}

variable "heredoc_var" {
  type = "string"
  default = <<EOF2
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF2
}

variable "integer_var" {
  type = "string"
  default = 123 # line comment example
}

variable "boolean_var" {
  type = "string"
  default = true
}

variable "list_var" {
  # lead comment example 2
  # lead comment example 3
  /* multi line comment 1
     more data
     more data
   */
  type = "list"
  default = [1,2,true,"hello"]
}

variable "map_var" {
  type = "map"
  default = {
    us-east-1 = true
    us-west-2 = false
  }
}

variable "inline_map_var" {
  type = "map"
  default = { us-east-1 = true, us-west-2 = false }
}

variable "string_key_map_var" {
  type = "map"
  default = { "us-east-1" = true, us-west-2 = false }
}

module "simple_module" {
 count = 10
}