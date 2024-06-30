
resource "aws_ecr_repository" "my-ecr" {
  name                 = "repo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "repositoryPolicy" {
  repository = aws_ecr_repository.my-ecr.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Delete older images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 2
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}


locals {

  docker_login_command = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  docker_build_command = "docker build -f ../docker/Dockerfile -t ${aws_ecr_repository.my-ecr.name} ../docker"
  docker_tag_command   = "docker tag ${aws_ecr_repository.my-ecr.name}:latest ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${aws_ecr_repository.my-ecr.name}:latest"
  docker_push_command  = "docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${aws_ecr_repository.my-ecr.name}:latest"
}

# This resource authenticates you to the ECR service
resource "null_resource" "docker_login" {
  provisioner "local-exec" {
    command = local.docker_login_command
  }
  triggers = {
    "run_at" = timestamp()
  }
  depends_on = [aws_ecr_repository.my-ecr]
}

# This resource builds the docker image from the Dockerfile in the app folder
resource "null_resource" "docker_build" {
  provisioner "local-exec" {
    working_dir = "../docker/"
    #interpreter = ["/bin/bash" ,"-c"]
    command = local.docker_build_command
  }
  triggers = {
    "run_at" = timestamp()
  }
  depends_on = [null_resource.docker_login]
}

# This resource tags the image 
resource "null_resource" "docker_tag" {
  provisioner "local-exec" {
    command = local.docker_tag_command
  }
  triggers = {
    "run_at" = timestamp()
  }
  depends_on = [null_resource.docker_build]
}

# This resource pushes the docker image to the ECR repo
resource "null_resource" "docker_push" {
  provisioner "local-exec" {
    command = local.docker_push_command
  }
  triggers = {
    "run_at" = timestamp()
  }
  depends_on = [null_resource.docker_tag]
}