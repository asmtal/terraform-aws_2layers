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

data "terraform_remote_state" "alb" {
        backend                 = "local"
        config {
                path            = "../alb/terraform.tfstate"
        }
}

//data "aws_alb" "front-dns_name" {
 // dns_name = "${data.terraform_remote_state.alb.front-dns_name}"
//}

resource "aws_route53_record" "core" {
  zone_id = "Z3P2BXUX8FSG24"
  name    = "teste-auto-front"
  type    = "CNAME"
  ttl     = "300"
  //records = ["${data.aws_alb.front-dns_name.dns_name}"]
  records = ["${data.terraform_remote_state.alb.front-dns_name}"]
}
