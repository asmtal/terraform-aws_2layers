output "vpc_security_group_id" {
  value		= "${aws_security_group.vpc_rule.id}"
}

output "back_security_group_id" {
  value         = "${aws_security_group.back_rule.id}"
}

output "front_security_group_id" {
  value         = "${aws_security_group.front_rule.id}"
}

output "alb_front_security_group_id" {
  value         = "${aws_security_group.alb_front_rule.id}"
}
