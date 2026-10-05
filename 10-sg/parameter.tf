resource "aws_ssm_parameter" "mysql-sg-id"{
    name = "/${var.project_name}/${var.environment}/mysql_sg_id"
    type = "String"
    value = module.mysql_sg.sg_id
}

resource "aws_ssm_parameter" "backend-sg-id"{
    name = "/${var.project_name}/${var.environment}/backend_sg_id"
    type = "String"
    value = module.backend_sg.sg_id
}

resource "aws_ssm_parameter" "frontend-sg-id"{
    name = "/${var.project_name}/${var.environment}/frontend_sg_id"
    type = "String"
    value = module.frontend_sg.sg_id
}

resource "aws_ssm_parameter" "bastion-sg-id"{
    name = "/${var.project_name}/${var.environment}/bastion_sg_id"
    type = "String"
    value = module.bastion_sg.sg_id
}

resource "aws_ssm_parameter" "alb-sg-id"{
    name = "/${var.project_name}/${var.environment}/alb_sg_id"
    type = "String"
    value = module.alb_sg.sg_id
}