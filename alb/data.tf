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

data "terraform_remote_state" "firewall" {
        backend                 = "local"
        config {
                path            = "../firewall/terraform.tfstate"
        }
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
}

data "aws_security_group" "vpc_firewall" {
  id = "${data.terraform_remote_state.firewall.vpc_security_group_id}"
}

data "aws_security_group" "back_firewall" {
  id = "${data.terraform_remote_state.firewall.back_security_group_id}"
}

data "aws_subnet" "private0" {
  id = "${data.terraform_remote_state.vpc.private_subnets[0]}"
}

data "aws_subnet" "private1" {
  id = "${data.terraform_remote_state.vpc.private_subnets[1]}"
}

data "aws_subnet" "private2" {
  id = "${data.terraform_remote_state.vpc.private_subnets[2]}"
}

data "aws_security_group" "front_firewall" {
  id = "${data.terraform_remote_state.firewall.front_security_group_id}"
}

data "aws_subnet" "public0" {
  id = "${data.terraform_remote_state.vpc.public_subnets[0]}"
}

data "aws_subnet" "public1" {
  id = "${data.terraform_remote_state.vpc.public_subnets[1]}"
}

data "aws_subnet" "public2" {
  id = "${data.terraform_remote_state.vpc.public_subnets[2]}"
}

