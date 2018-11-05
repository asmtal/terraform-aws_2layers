provider "aws" {
  region = "us-east-1"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
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

data "terraform_remote_state" "alb" {
        backend                 = "local"
        config {
                path            = "../alb/terraform.tfstate"
        }
}

data "terraform_remote_state" "sg" {
        backend                 = "local"
        config {
                path            = "../sg/terraform.tfstate"
        }
}

data "aws_security_group" "vpc_sg" {
  id = "${data.terraform_remote_state.sg.vpc_security_group_id}"
}

data "aws_security_group" "back_sg" {
  id = "${data.terraform_remote_state.sg.back_security_group_id}"
}

data "aws_security_group" "front_sg" {
  id = "${data.terraform_remote_state.sg.front_security_group_id}"
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
}

data "aws_security_group" "sg" {
  id = "${data.terraform_remote_state.sg.vpc_security_group_id}"
}

data "aws_alb_target_group" "back-alb_target" {
  arn = "${data.terraform_remote_state.alb.back-target_group_arns[0]}"
}

data "aws_alb_target_group" "front-alb_target" {
  arn = "${data.terraform_remote_state.alb.front-target_group_arns[0]}"
}

