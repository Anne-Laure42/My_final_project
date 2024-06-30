# --- APPLICATION LOAD BALANCER ---
resource "aws_lb" "ecs_alb" {
  internal           = false
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.public-subnets : subnet.id]
  # Referencing the security group
  security_groups = ["${aws_security_group.alb_security_group.id}"]
  idle_timeout    = "1000"

  tags = {
    Name = "${var.project}-elb"
  }
}


# --- ALB LISTENER---

# Define an HTTP Listener for the ALB : route the request to target group

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.id
  }
}


# --- ALB TARGET GROUP ---

# Define the target group and a health check on the application

resource "aws_lb_target_group" "alb_target_group" {
  vpc_id      = aws_vpc.vpc.id
  protocol    = "HTTP"
  port        = 80
  target_type = "instance"

  tags = {
    Name = "${var.project}-ecs-target-group"
  }

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    matcher             = 200
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  depends_on = [aws_lb.ecs_alb]
}
