resource "aws_ssm_parameter" "backend-instance" {
  name  = "/${var.project_name}/${var.environment}/backend-ec2-id"
  type  = "String"
  value = aws_instance.backend-instance.private_ip
}
