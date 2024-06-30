resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project}-subnet_group"
  subnet_ids = var.db_subnets_cidrs

  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_db_instance" "my-database" {
  allocated_storage    = 10 # The amount of storage in gibibytes (GiB) to allocate for the DB instance
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro" # The compute and memory capacity of the DB instance
  username             = var.db-username
  password             = var.db-password
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.db-security-group.id]
  publicly_accessible = false
  skip_final_snapshot    = true # Disable taking a final backup when you destroy the database 
  multi_az               = var.multi_az_db

  tags = {
    Name = "${var.project}-mysql-database"
  }
}
