# # --- DB Password ---

# # Generate a random password
# resource "random_password" "db_password" {
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }

# # Store the password in SSM Parameter Store
# resource "aws_ssm_parameter" "db_password" {
#   name  = "/${var.project}/database/password"
#   type  = "SecureString"
#   value = random_password.db_password.result

#   tags = {
#     environment = "${var.project}-password"
#   }
# }


# # --- DB Username ---

# # Generate a random username
# resource "random_string" "db_username" {
#   length  = 12
#   special = false
# }

# # Store the username in SSM Parameter Store
# resource "aws_ssm_parameter" "db_username" {
#   name  = "/${var.project}/database/username"
#   type  = "SecureString"
#   value = random_string.db_username.result
# }