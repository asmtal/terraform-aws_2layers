provider "aws" {
  region = "us-east-1"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

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

data "aws_subnet_ids" "all" {
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
}

resource "aws_vpc_peering_connection" "bastion_x_terraform-project" {
  peer_vpc_id   = "vpc-a0f4b1c7"
  vpc_id        = "${data.aws_subnet_ids.all.vpc_id}"
  auto_accept   = true
  //name		= "bastion_x_terraform-project"
  //peer_region   = "us-east-1"
  tags { Name = "bastion_x_terraform-project" }
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}
