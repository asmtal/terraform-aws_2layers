# Launch configuration and autoscaling group
######
module "front-asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${var.name-prefix}-front-asg"

  lc_name = "terraform-project-front-lc"

  target_group_arns            = ["${data.aws_alb_target_group.front-alb_target.arn}"]
  image_id                     = "${var.image_id["front"]}"
  instance_type                = "${var.instance_type["front"]}"
  key_name                     = "${var.key_name}"
  security_groups              = ["${data.aws_security_group.vpc_sg.id}","${data.aws_security_group.front_sg.id}","${data.terraform_remote_state.sg.alb_front_security_group_id}"]
  associate_public_ip_address  = true
  recreate_asg_when_lc_changes = false

  ebs_block_device = [
    {
      device_name           = "/dev/sdj"
      volume_type           = "gp2"
      volume_size           = "1"
      delete_on_termination = true
    },
    {
      device_name           = "/dev/sdg"
      volume_type           = "gp2"
      volume_size           = "6"
      delete_on_termination = true
    },
    {
      device_name           = "/dev/sdk"
      volume_type           = "gp2"
      volume_size           = "8"
      delete_on_termination = true
    },
    {
      device_name           = "/dev/sdi"
      volume_type           = "gp2"
      volume_size           = "1"
      delete_on_termination = true
    },
    {
      device_name           = "/dev/sdf"
      volume_type           = "gp2"
      volume_size           = "6"
      delete_on_termination = true
    },
    {
      device_name           = "/dev/sdh"
      volume_type           = "gp2"
      volume_size           = "1"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size           = "160"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name                  = "${var.name_prefix}-asg"
  vpc_zone_identifier       = ["${data.aws_subnet_ids.all.ids}"]
  health_check_type         = "EC2"
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "${var.name_prefix}"
      propagate_at_launch = true
    },
  ]

  tags_as_map = {
    extra_tag1 = "extra_value1"
    extra_tag2 = "extra_value2"
  }
}
