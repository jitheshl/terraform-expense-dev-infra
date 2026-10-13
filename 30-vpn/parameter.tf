resource "aws_ssm_parameter" "ec2-vpn" {
  name  = "/${var.project_name}/${var.environment}/vpn-ec2-id"
  type  = "String"
  value = aws_instance.vpn-instance.public_ip
}
