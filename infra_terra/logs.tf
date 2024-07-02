# --- Cloud Watch Logs Group ---

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/logs"
  retention_in_days = 14
}


# # --- Cloud Watch Logs Stream ---

resource "aws_cloudwatch_log_stream" "cl_log_stream" {
  name           = "/aws/kinesisfirehose/${var.project}-kinesis-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}


# --- Cloud Watch Logs Subscription Filter ---

resource "aws_cloudwatch_log_subscription_filter" "cl_log_filter" {
  name            = "${var.project}-logs-subscription"
  log_group_name  = aws_cloudwatch_log_group.log_group.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.firehose_delivery_stream.arn
  role_arn        = aws_iam_role.cloudwatch_logs.arn

  depends_on = [
    aws_kinesis_firehose_delivery_stream.firehose_delivery_stream,
    aws_iam_role_policy.cloudwatch_logs
  ]
}


# --- Firehose delivery stream ---

resource "aws_kinesis_firehose_delivery_stream" "firehose_delivery_stream" {
  name        = "ecs-logs-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.ecs_logs_bucket.arn
    buffering_interval = 300
    buffering_size     = 5
    compression_format = "GZIP"

    #   cloudwatch_logging_options {
    #     enabled = "true"
    #     log_group_name = aws_cloudwatch_log_group.ecs.name
    #     log_stream_name = aws_cloudwatch_log_stream.cl_log_stream.name
    #   }
    # }

    # kinesis_source_configuration {
    #   kinesis_stream_arn  = aws_kinesis_stream.kinesis_stream.arn
    #   role_arn            = aws_iam_role.firehose_role.arn
    # }

  }
  tags = {
    Name = "${var.project}-firehose"
  }
  depends_on = [aws_iam_policy.firehose_policy]
}
