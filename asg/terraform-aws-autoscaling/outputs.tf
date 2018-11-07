output "terraform-project_launch_configuration_id" {
  description = "The ID of the launch configuration"
  value       = "${var.launch_configuration == "" && var.create_lc ? element(concat(aws_launch_configuration.terraform-project.*.id, list("")), 0) : var.launch_configuration}"
}

output "terraform-project_launch_configuration_name" {
  description = "The name of the launch configuration"
  value       = "${var.launch_configuration == "" && var.create_lc ? element(concat(aws_launch_configuration.terraform-project.*.name, list("")), 0) : ""}"
}

output "terraform-project_autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = "${element(concat(aws_autoscaling_group.terraform-project.*.id, list("")), 0)}"
}

output "terraform-project_autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = "${element(concat(aws_autoscaling_group.terraform-project.*.name, list("")), 0)}"
}

output "terraform-project_autoscaling_group_arn" {
  description = "The ARN for terraform-project AutoScaling Group"
  value       = "${element(concat(aws_autoscaling_group.terraform-project.*.arn, list("")), 0)}"
}

output "terraform-project_autoscaling_group_min_size" {
  description = "The minimum size of the autoscale group"
  value       = "${element(concat(aws_autoscaling_group.terraform-project.*.min_size, list("")), 0)}"
}

output "terraform-project_autoscaling_group_max_size" {
  description = "The maximum size of the autoscale group"
  value       = "${element(concat(aws_autoscaling_group.terraform-project.*.max_size, list("")), 0)}"
}

output "terraform-project_autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = "${element(concat(aws_autoscaling_group.terraform-project.*.desired_capacity, list("")), 0)}"
}

output "terraform-project_autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = "${element(concat(aws_autoscaling_group.terraform-project.*.default_cooldown, list("")), 0)}"
}

output "terraform-project_autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = "${element(concat(aws_autoscaling_group.terraform-project.*.health_check_grace_period, list("")), 0)}"
}

output "terraform-project_autoscaling_group_health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done"
  value       = "${element(concat(aws_autoscaling_group.terraform-project.*.health_check_type, list("")), 0)}"
}
