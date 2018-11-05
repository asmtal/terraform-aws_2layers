provider "aws" {
  region = "us-east-1"
}

/*
 -----------------------------
|#############################|
|# Security groups examples ##|
|#############################|
 -----------------------------
*/

################
# VPC default ##
################
resource "aws_security_group" "vpc_rule" {
  description	= "VPC Rule"
  name		= "${var.name_prefix}vpc-default_rule"
  vpc_id	= "${data.aws_subnet_ids.vpc.vpc_id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}","${var.bastion_cidr_block}"]
  }
  egress {
    from_port	= 0
    to_port	= 0
    protocol	= "-1"
    cidr_blocks	= ["0.0.0.0/0"]
  }
}

###############
# BACK rules ##
###############
resource "aws_security_group" "back_rule" {
  description   = "VPC Rule"
  name          = "${var.name_prefix}back_rule"
  vpc_id        = "${data.aws_subnet_ids.vpc.vpc_id}"
  ingress {
    from_port   = 8009
    to_port     = 8009
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################
# FRONT rules ##
################
resource "aws_security_group" "front_rule" {
  description   = "VPC Rule"
  name          = "${var.name_prefix}front_rule"
  vpc_id        = "${data.aws_subnet_ids.vpc.vpc_id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_front_rule" {
  description   = "VPC Rule"
  name          = "${var.name_prefix}alb_front_rule"
  vpc_id        = "${data.aws_subnet_ids.vpc.vpc_id}"
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

