module "mysql_sg"{
    source = "git::https://github.com/jitheshl/terraform-aws-security-group-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "mysql"
    sg_description = "creating the mysql security group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "backend_sg"{
    source = "git::https://github.com/jitheshl/terraform-aws-security-group-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "backend"
    sg_description = "creating the backend security group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "frontend_sg"{
    source = "git::https://github.com/jitheshl/terraform-aws-security-group-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "frontend"
    sg_description = "creating the frontend security group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "bastion_sg"{
    source = "git::https://github.com/jitheshl/terraform-aws-security-group-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "bastion"
    sg_description = "creating the bastion security group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "alb_sg"{
    source = "git::https://github.com/jitheshl/terraform-aws-security-group-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "alb"
    sg_description = "creating the alb security group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_security_group_rule" "alb_bastion"{
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.sg_id
    security_group_id = module.alb_sg.sg_id
}

resource "aws_security_group_rule" "bastion_public"{
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["157.50.75.225/32"]
    security_group_id = module.bastion_sg.sg_id
}