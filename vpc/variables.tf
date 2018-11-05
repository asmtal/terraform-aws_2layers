variable "name_prefix" {
  default				= "terraform-project"
}

variable "environment" {
  default                               = "DEV"
}

variable "user" {
  default                               = "ec2-user"
}

variable "bastion_vpc_id" {}
