locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  private-subnet-id = split(",",data.aws_ssm_parameter.private-subnet-id.value)
  alb-sg-id = data.aws_ssm_parameter.alb-sg-id.value
}
