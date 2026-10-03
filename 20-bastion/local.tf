locals {
  public_subnet_id = split(",",data.aws_ssm_parameter.public-subnet-id.value)
}
