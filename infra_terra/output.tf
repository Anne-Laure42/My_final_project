output "repositoryUrl" {
  value = aws_ecr_repository.my-ecr.repository_url
}

output "alb_url" {
  value = aws_lb.ecs_alb.dns_name
}