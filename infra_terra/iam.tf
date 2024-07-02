# --- EC2 Container Service Role ---

data "aws_iam_policy_document" "ecs_node_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_node_role" {
  name_prefix        = "demo-ecs-node-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_node_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  role       = aws_iam_role.ecs_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


# --- ECS Instance Service Role ---

resource "aws_iam_instance_profile" "ecs_profile" {
  name_prefix = "demo-ecs-node-profile"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_node_role.name
}


# --- ECS Task Execution Role ---

data "aws_iam_policy_document" "ecs_task_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name_prefix        = "demo-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role" "ecs_exec_role" {
  name_prefix        = "demo-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec_role_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# --- ECS Service Role ---

data "aws_iam_policy" "ecsServiceRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
data "aws_iam_policy_document" "ecsServiceRolePolicy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ecsServiceRole" {
  name               = "ecsServiceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecsServiceRolePolicy.json
}
resource "aws_iam_role_policy_attachment" "ecsServicePolicy" {
  role       = aws_iam_role.ecsServiceRole.name
  policy_arn = data.aws_iam_policy.ecsServiceRolePolicy.arn
}


# --- Firehose Role ---

data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "firehose_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

resource "aws_iam_policy" "firehose_policy" {
  name        = "firehose_policy"
  description = "Policy for Firehose to access S3"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:PutObjectAcl",
          "s3:PutObjectVersionAcl"
        ],
        "Resource" : [
          "${aws_s3_bucket.ecs_logs_bucket.arn}",
          "${aws_s3_bucket.ecs_logs_bucket.arn}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:CreateLogStream",
          "logs:PutSubscriptionFilter",
          "logs:DeleteSubscriptionFilter"
        ],
        "Resource" : [
          "arn:aws:logs:*:*:log-group:*:log-stream:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_policy_attachment" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}


# --- CloudWatch Logs to Kinesis Firehose ---


# Create a role that allows CloudWatch Logs to send logs to Kinesis Firehose

resource "aws_iam_role" "cloudwatch_logs" {
  name = "cloudwatch_logs_to_firehose"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "logs.eu-west-3.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : "",
      },
    ],
  })
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  role = aws_iam_role.cloudwatch_logs.name

  policy = jsonencode({
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : ["firehose:*"],
        "Resource" : [aws_kinesis_firehose_delivery_stream.firehose_delivery_stream.arn],
      },
    ],
  })
}


# # --- SSM Paramater Policy ---


# resource "aws_iam_policy" "ecs_task_ssm_policy" {
#   name        = "${var.project}-ecs-task-ssm-policy"
#   description = "IAM policy for ECS Task execution"

#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : "ssm:DescribeParameters",
#         "Resource" : "*"
#       },
#       {
#         "Effect" : "Deny",
#         "Action" : [
#           "ssm:GetParameter",
#           "ssm:DeleteParameter",
#           "ssm:PutParameter"
#         ],
#         "Resource" : "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
#   role       = aws_iam_role.ecs_exec_role.name
#   policy_arn = aws_iam_policy.ecs_task_ssm_policy.arn
# }