output "repository_url" {
  value = aws_ecr_repository.my_ecr.repository_url
}

output "alb_url" {
  value = aws_lb.ecs_alb.dns_name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.app.name
}

# output "db_instance_endpoint" {
#   description = "The endpoint of the RDS instance"
#   value       = aws_db_instance.my_rds_database.endpoint
# }

