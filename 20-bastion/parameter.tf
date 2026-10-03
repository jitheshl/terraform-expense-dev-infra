resource "aws_ssm_parameter" "ec2-bastion" {
  name  = "/${var.project_name}/${var.environment}/bastion-ec2-id"
  type  = "String"
  value = aws_instance.bastion-instance.public_ip
}
