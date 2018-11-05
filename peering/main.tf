provider "aws" {
  region                                = "us-east-1"
  skip_get_ec2_platforms                = true
  skip_metadata_api_check               = true
  skip_region_validation                = true
  skip_credentials_validation           = true
  skip_requesting_account_id            = true
}

terraform {
        backend "local" {
                path                    = "terraform.tfstate"
        }
}

data "terraform_remote_state" "vpc" {
        backend                         = "local"
        config {
                path                    = "./terraform.tfstate"
        }
}

resource "aws_vpc_peering_connection" "bastion2project" {
  peer_vpc_id                           = "${var.bastion_vpc_id}"
  vpc_id                                = "${data.terraform_remote_state.vpc.vpc_id}"
  auto_accept                           = true
  tags { Name                           = "bastion2${var.name_prefix}" }
  accepter {
    allow_remote_vpc_dns_resolution     = true
  }
  requester {
    allow_remote_vpc_dns_resolution     = true
  }
}
