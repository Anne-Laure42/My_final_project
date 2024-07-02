# --- ECS Cluster ---

# Create a new ECS cluster
resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "my-ecs-cluster"

  lifecycle {
    create_before_destroy = true
  }

  #   tags = {
  #     Name = "${var.project}_ECSCluster"
  #   }
}


# --- ECS Task Definition ---

resource "aws_ecs_task_definition" "app" {
  family             = "demo-app"
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_exec_role.arn
  network_mode       = "bridge"
  cpu                = 512
  memory             = 512

  container_definitions = jsonencode([{
    name         = var.ecs_container_name,
    network_mode = "bridge",
    image        = "${aws_ecr_repository.my_ecr.repository_url}:latest",
    essential    = true,
    portMappings = [{ containerPort = var.app_port, hostPort = 0 }]

    # environment = [
    #   {
    #     name  = "DB_HOST"
    #     value = aws_db_instance.my_rds_database.endpoint
    #   },
    #   {
    #     name  = "DB_PORT"
    #     value = "3306"
    #   },
    #   {
    #     name  = "DB_USER"
    #     value = aws_ssm_parameter.db_username.value
    #   },
    #   {
    #     name  = "DB_PASS"
    #     value = aws_ssm_parameter.db_password.value
    #   },
    #   {
    #       name  = "DB_NAME"
    #       value =  aws_db_instance.my_rds_database.db_name
    #   }
    # ]

    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-region"        = "eu-west-3",
        "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,
        "awslogs-stream-prefix" = "ecs"
      }
    },
  }])
}

# --- ECS Service ---

resource "aws_ecs_service" "app" {
  name            = "app"
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  iam_role        = aws_iam_role.ecsServiceRole.arn
  desired_count   = 2

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    base              = 1
    weight            = 1
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_target_group.alb_target_group]

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = var.ecs_container_name
    container_port   = var.app_port
  }
}