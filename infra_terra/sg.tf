# ------------------------------------------------------------------------------
# ALB Security Group
# ------------------------------------------------------------------------------

resource "aws_security_group" "alb_security_group" {
  name        = "alb_security_group"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.vpc.id

  lifecycle {
    create_before_destroy = true
  }
}

# Alb Security Group Rules - INBOUND
resource "aws_security_group_rule" "alb_inbound" {
  type              = "ingress"
  from_port         = 0 # Allows inbound HTTP access from any IPv4 address
  to_port           = 65535
  protocol          = "tcp"
  description       = "Allow http inbound traffic from internet"
  security_group_id = aws_security_group.alb_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow outbound traffic from ECS"
  security_group_id = aws_security_group.alb_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
}


# ------------------------------------------------------------------------------
# ECS app Security Group 
# ------------------------------------------------------------------------------

# ECS Security Group Rules - INBOUND
resource "aws_security_group" "ec2_security_group" {
  name        = "ecs-security-group"
  description = "ECS Security Group"
  vpc_id      = aws_vpc.vpc.id

   lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ecs-ingress" {
  type                     = "ingress"
  from_port                = 0 # Allows inbound traffic to ec2 from ALB Security Group
  to_port                  = 0
  protocol                 = "-1"
  description              = "Allow inbound traffic from ALB"
  security_group_id        = aws_security_group.ec2_security_group.id
  source_security_group_id = aws_security_group.alb_security_group.id
}

# ECS app Security Group Rules - OUTBOUND
resource "aws_security_group_rule" "ecs-all-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow outbound traffic from ECS"
  security_group_id = aws_security_group.ec2_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
}



# ------------------------------------------------------------------------------
# DB Security Group 
# ------------------------------------------------------------------------------

resource "aws_security_group" "db_security_group" {
  name        = "database-security-group"
  description = "Database security group"
  vpc_id      = aws_vpc.vpc.id


lifecycle {
  create_before_destroy = true
}
}

resource "aws_security_group_rule" "db-ingress" {
  security_group_id        = aws_security_group.db_security_group.id
  type                     = "ingress"
  from_port                = 3306 
  to_port                  = 3306
  protocol                 = "tcp"
  description       = "Allows traffic from only the ECS Security Group"
  source_security_group_id = aws_security_group.ecs_sg.id
}

resource "aws_security_group_rule" "db-egress" {
  security_group_id = aws_security_group.db-security-group.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}