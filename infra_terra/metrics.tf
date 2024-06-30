# Cloudwatch Alarm for ECS Cluster

resource "aws_cloudwatch_metric_alarm" "ecs-alert_High-CPUReservation" {
  alarm_name          = "ECS-High_CPUResv"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  period              = "60"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  # second
  statistic         = "Average"
  threshold         = "80"
  alarm_description = ""

  metric_name = "CPUReservation"
  namespace   = "AWS/ECS"
  dimensions = {
    ClusterName = "${aws_ecs_cluster.my_ecs_cluster.name}"
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = []
  alarm_actions = [
    "${aws_sns_topic.asg_alerts.arn}",
  "${aws_autoscaling_policy.ecs-asg_increase.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "ecs-alert_Low-CPUReservation" {
  alarm_name          = "ECS_Low_CPUResv"
  comparison_operator = "LessThanThreshold"

  period              = "300"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  statistic         = "Average"
  threshold         = "40"
  alarm_description = ""

  metric_name = "CPUReservation"
  namespace   = "AWS/ECS"
  dimensions = {
    ClusterName = "${aws_ecs_cluster.my_ecs_cluster.name}"
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = []
  alarm_actions = [
    "${aws_sns_topic.asg_alerts.arn}",
    "${aws_autoscaling_policy.ecs-asg_decrease.arn}",
  ]
}


resource "aws_cloudwatch_metric_alarm" "ecs-alert_High-MemReservation" {
  alarm_name          = "ECS-High_MemResv"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  period              = "60"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  statistic         = "Average"
  threshold         = "80"
  alarm_description = ""

  metric_name = "MemoryReservation"
  namespace   = "AWS/ECS"
  dimensions = {
    ClusterName = "${aws_ecs_cluster.my_ecs_cluster.name}"
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = []
  alarm_actions = [
    "${aws_sns_topic.asg_alerts.arn}",
    "${aws_autoscaling_policy.ecs-asg_increase.arn}",
  ]
}

resource "aws_cloudwatch_metric_alarm" "ecs-alert_Low-MemReservation" {
  alarm_name          = "ECS-Low_MemResv"
  comparison_operator = "LessThanThreshold"

  period              = "300"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  statistic         = "Average"
  threshold         = "40"
  alarm_description = ""

  metric_name = "MemoryReservation"
  namespace   = "AWS/ECS"
  dimensions = {
    ClusterName = "${aws_ecs_cluster.my_ecs_cluster.name}"
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = []
  alarm_actions = [
    "${aws_sns_topic.asg_alerts.arn}",
    "${aws_autoscaling_policy.ecs-asg_decrease.arn}",
  ]
}


# Set Up SNS Topic for Alarm Notifications
resource "aws_sns_topic" "asg_alerts" {
  name = "${var.project}_asg-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.asg_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}