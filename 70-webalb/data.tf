data "aws_ssm_parameter" "vpc_id"{
   name = "/${var.project_name}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "public-subnet-id"{
   name = "/${var.project_name}/${var.environment}/public-subnet-id"
}

data "aws_ssm_parameter" "web-alb-sg-id"{
   name = "/${var.project_name}/${var.environment}/web_alb_sg_id"
}