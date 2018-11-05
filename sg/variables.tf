terraform {
        backend "local" {
                path            = "terraform.tfstate"
        }
}

data "terraform_remote_state" "vpc" {
        backend                 = "local"
        config {
                path            = "../vpc/terraform.tfstate"
        }
}

data "aws_subnet_ids" "vpc" {
  vpc_id 	 = "${data.terraform_remote_state.vpc.vpc_id}"
}

variable "name_prefix" {
  default = "terraform-project_"
}

variable "vpc_cidr_block" {
  default = "10.200.0.0/16"
}

variable "bastion_cidr_block" {
  default = "10.1.24.0/22"
}
