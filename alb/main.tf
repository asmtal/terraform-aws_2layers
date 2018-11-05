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

data "terraform_remote_state" "sg" {
        backend                 = "local"
        config {
                path            = "../sg/terraform.tfstate"
        }
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
}

data "aws_security_group" "vpc_sg" {
  id = "${data.terraform_remote_state.sg.vpc_security_group_id}"
}

/*
 ----------
|##########|
|## BACK ##|
|##########|
 ----------
----------------------------------------------
*/
data "aws_security_group" "back_sg" {
  id = "${data.terraform_remote_state.sg.back_security_group_id}"
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

module "back-alb" {
  source                        = "terraform-aws-modules/alb/aws"
  load_balancer_name            = "terraform-project-back-alb"
  security_groups               = ["${data.aws_security_group.vpc_sg.id}","${data.aws_security_group.back_sg.id}"]
  load_balancer_is_internal	= true
  logging_enabled		= false
  subnets                       = ["${data.aws_subnet.private0.id}","${data.aws_subnet.private1.id}","${data.aws_subnet.private2.id}"]
  tags                          = "${map("Environment", "test")}"
  vpc_id                        = "${data.aws_subnet_ids.all.vpc_id}"
  http_tcp_listeners            = "${list(map("port", "8080", "protocol", "HTTP"))}"
  http_tcp_listeners_count      = "1"
  http_tcp_listeners            = "${list(map("port", "8009", "protocol", "HTTP"))}"
  http_tcp_listeners_count      = "1"
  target_groups                 = "${list(map("name", "terraform-project-back-tg", "backend_protocol", "HTTP", "backend_port", "8080", "health_check_path", "/index.html"))}"
  target_groups_count           = "1"
}
/*
----------------------------------------------
*/

/*
 -----------
|###########|
|## FRONT ##|
|###########|
 -----------
----------------------------------------------
*/
data "aws_security_group" "front_sg" {
  id = "${data.terraform_remote_state.sg.front_security_group_id}"
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

module "front-alb" {
  source                        = "terraform-aws-modules/alb/aws"
  load_balancer_name            = "terraform-project-front-alb"
  security_groups               = ["${data.aws_security_group.vpc_sg.id}","${data.aws_security_group.front_sg.id}"]
  load_balancer_is_internal     = false
  logging_enabled               = false
  subnets                       = ["${data.aws_subnet.public0.id}","${data.aws_subnet.public1.id}","${data.aws_subnet.public2.id}"]
  tags                          = "${map("Environment", "test")}"
  vpc_id                        = "${data.aws_subnet_ids.all.vpc_id}"
  https_listeners               = "${list(map("certificate_arn", "arn:aws:acm:us-east-1:766073738479:certificate/319fee94-d23f-4670-8656-fd1c02c22f4b", "port", 443))}"
  https_listeners_count         = "1"
  http_tcp_listeners            = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count      = "1"
  target_groups                 = "${list(map("name", "terraform-project-front-tg", "backend_protocol", "HTTPS", "backend_port", "443", "health_check_path", "/index.html"))}"
  target_groups_count           = "1"
}
/*
----------------------------------------------
*/

