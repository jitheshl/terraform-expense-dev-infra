locals {
  private_subnet_id = split(",",data.aws_ssm_parameter.private-subnet-id.value)
  resource_name = "${var.project_name}-${var.environment}-backend"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  backend_sg_id = data.aws_ssm_parameter.backend_sg_id.value
  alb_listener_arn = data.aws_ssm_parameter.alb_listener_arn.value
}
