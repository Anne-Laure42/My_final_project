# resource "aws_db_subnet_group" "db_subnet_group" {
#   name       = "${var.project}-subnet_group"
#   subnet_ids = [for subnet in aws_subnet.database_subnets : subnet.id]

#   tags = {
#     Name = "${var.project}-db-subnet-group"
#   }
# }

# resource "aws_db_instance" "my_rds_database" {
#   allocated_storage      = 10 # The amount of storage in gibibytes (GiB) to allocate for the DB instance
#   engine                 = "mysql"
#   engine_version         = "8.0.35"
#   instance_class         = "db.t3.micro" # The compute and memory capacity of the DB instance
#   username               = aws_ssm_parameter.db_username.value
#   password               = aws_ssm_parameter.db_password.value
#   port = "3306"
#   db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
#   vpc_security_group_ids = [aws_security_group.db_security_group.id]
#   publicly_accessible    = false
#   skip_final_snapshot    = true # Disable taking a final backup when you destroy the database 
#   multi_az = false

#   tags = {
#     Name = "${var.project}-mysql-database"
#   }
# }
