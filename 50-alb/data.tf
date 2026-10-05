data "aws_ssm_parameter" "vpc_id"{
   name = "/${var.project_name}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "private-subnet-id"{
   name = "/${var.project_name}/${var.environment}/private-subnet-id"
}

data "aws_ssm_parameter" "alb-sg-id"{
   name = "/${var.project_name}/${var.environment}/alb_sg_id"
}