variable "name_prefix" {
  default			= "terraform-project"
}

variable "environment" {
  default			= "DEV"
}

variable "user" {
  default			= "ec2-user"
}

variable "vpc_cidr_block" {
  default			= "10.200.0.0/16"
}

variable "bastion_cidr_block" {
  default			= "10.1.24.0/22"
}
