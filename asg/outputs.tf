output "back-lc-id" {
  description = "The ID of the launch configuration"
  value       = "${module.back-asg.this_launch_configuration_id}"
}

output "back-asg-id" {
  description = "The autoscaling group id"
  value       = "${module.back-asg.this_autoscaling_group_id}"
}

output "front-lc-id" {
  description = "The ID of the launch configuration"
  value       = "${module.front-asg.this_launch_configuration_id}"
}

output "front-asg-id" {
  description = "The autoscaling group id"
  value       = "${module.front-asg.this_autoscaling_group_id}"
}
