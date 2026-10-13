locals {
  public_subnet_id = split(",",data.aws_ssm_parameter.public-subnet-id.value)
  resource_name = "${var.project_name}-${var.environment}-frontend"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  frontend_sg_id = data.aws_ssm_parameter.frontend_sg_id.value
  web_alb_listener_arn = data.aws_ssm_parameter.web_alb_listener_arn.value
}
