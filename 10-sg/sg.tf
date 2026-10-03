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