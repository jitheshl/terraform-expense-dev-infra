locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  public-subnet-id = split(",",data.aws_ssm_parameter.public-subnet-id.value)
  web-alb-sg-id = data.aws_ssm_parameter.web-alb-sg-id.value
}
