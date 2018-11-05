output "back-alb_id" {
  value = "${module.back-alb.load_balancer_id}"
}

output "back-http_tcp_listener_arns" {
  value = "${module.back-alb.http_tcp_listener_arns}"
}

output "back-https_listener_arns" {
  value = "${module.back-alb.https_listener_arns}"
}

output "back-target_group_arns" {
  value = "${module.back-alb.target_group_arns}"
}

output "front-alb_id" {
  value = "${module.front-alb.load_balancer_id}"
}

output "front-http_tcp_listener_arns" {
  value = "${module.front-alb.http_tcp_listener_arns}"
}

output "front-https_listener_arns" {
  value = "${module.front-alb.https_listener_arns}"
}

output "front-target_group_arns" {
  value = "${module.front-alb.target_group_arns}"
}

output "front-dns_name" {
  value = "${module.front-alb.dns_name}"
}

output "back-dns_name" {
  value = "${module.back-alb.dns_name}"
}

