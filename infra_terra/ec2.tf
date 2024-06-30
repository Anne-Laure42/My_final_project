# Create a launch template which defines the template used by the auto-scaling group to provision 
# and maintain a desired/required number of EC2 instances in a cluster

# Choose an optimazed Amazon Linux image for ECS (recommanded)

resource "aws_launch_template" "ecs_ec2" {
  name_prefix = "${var.project}-ecs-template"
  image_id    = var.image_id
  # key_name                = "terra" # Authorize SSH connection for EC2 debugging  
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  user_data              = base64encode(templatefile("user_data.sh", { var1 = "my-ecs-cluster" }))

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  monitoring { enabled = true }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_profile.name
  }

  depends_on = [aws_internet_gateway.igw]
}