# --- ECS ASG ---

resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "${var.project}-ecs-asg"
  vpc_zone_identifier       = [for subnet in aws_subnet.private-subnets : subnet.id]
  min_size                  = 2
  max_size                  = 4
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = true

  lifecycle {
    create_before_destroy = true
  }

  launch_template {
    id      = aws_launch_template.ecs_ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecs-cluster"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

# --- ASG POLICIES ---

resource "aws_autoscaling_policy" "ecs-asg_decrease" {
  name                   = "${var.project}-asg_decrease"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
}

resource "aws_autoscaling_policy" "ecs-asg_increase" {
  name                   = "${var.project}_asg__Increase"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
}