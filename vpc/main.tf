provider "aws" {
  region = "us-east-1"

}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "terraform-project"

  cidr = "10.200.0.0/16"

  azs                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets     = ["10.200.1.0/24", "10.200.2.0/24", "10.200.3.0/24"]
  public_subnets      = ["10.200.11.0/24", "10.200.12.0/24", "10.200.13.0/24"]
  /*
  database_subnets    = ["10.200.21.0/24", "10.200.22.0/24", "10.200.23.0/24"]
  elasticache_subnets = ["10.200.31.0/24", "10.200.32.0/24", "10.200.33.0/24"]
  redshift_subnets    = ["10.200.41.0/24", "10.200.42.0/24", "10.200.43.0/24"]
  intra_subnets       = ["10.200.51.0/24", "10.200.52.0/24", "10.200.53.0/24"]
  */
  create_database_subnet_group = false

  enable_nat_gateway = true
  single_nat_gateway = true
  reuse_nat_ips       = true
  external_nat_ip_ids = ["${aws_eip.nat.*.id}"]

  enable_vpn_gateway = true

  enable_s3_endpoint       = false
  enable_dynamodb_endpoint = false

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "service.consul"
  dhcp_options_domain_name_servers = ["127.0.0.1", "10.200.0.2"]

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "terraform-project"
  }
}

resource "aws_eip" "nat" {
  count = 3

  vpc = true
}
