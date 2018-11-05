provider "aws" {
  region				= "us-east-1"
  skip_get_ec2_platforms		= true
  skip_metadata_api_check		= true
  skip_region_validation		= true
  skip_credentials_validation		= true
  skip_requesting_account_id		= true
}

module "vpc" {
  source				= "terraform-aws-modules/vpc/aws"
  name					= "${var.name_prefix}-vpc"
  cidr					= "10.200.0.0/16"
  azs					= ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets			= ["10.200.1.0/24", "10.200.2.0/24", "10.200.3.0/24"]
  public_subnets			= ["10.200.11.0/24", "10.200.12.0/24", "10.200.13.0/24"]
  create_database_subnet_group		= false
  enable_nat_gateway			= true
  single_nat_gateway			= true
  reuse_nat_ips				= true
  external_nat_ip_ids			= ["${aws_eip.nat.*.id}"]
  enable_vpn_gateway			= true
  enable_s3_endpoint			= false
  enable_dynamodb_endpoint		= false
  enable_dhcp_options			= true
  dhcp_options_domain_name		= "service.consul"
  dhcp_options_domain_name_servers	= ["127.0.0.1", "10.200.0.2"]

  tags = {
    Owner				= "${var.user}"
    Environment				= "${var.environment}"
    Name				= "${var.name_prefix}"
  }
}

resource "aws_eip" "nat" {
  count					= 3
  vpc					= true
}
