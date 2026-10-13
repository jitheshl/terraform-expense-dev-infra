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

# we need to create 22,443,943,1194
module "vpn_sg"{
    source = "git::https://github.com/jitheshl/terraform-aws-security-group-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "vpn"
    sg_description = "creating the vpn security group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

module "web_alb_sg"{
    source = "git::https://github.com/jitheshl/terraform-aws-security-group-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "web-alb"
    sg_description = "creating the web_alb security group"
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

resource "aws_security_group_rule" "vpc-22"{
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.vpn_sg.sg_id
}

resource "aws_security_group_rule" "vpc-443"{
    type = "ingress"
    from_port = 443
    to_port =443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.vpn_sg.sg_id
}

resource "aws_security_group_rule" "vpc-943"{
    type = "ingress"
    from_port = 943
    to_port =943
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.vpn_sg.sg_id
}

resource "aws_security_group_rule" "web_alb_http"{
    type = "ingress"
    from_port = 80
    to_port =80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.web_alb_sg.sg_id
}

resource "aws_security_group_rule" "vpc-1194"{
    type = "ingress"
    from_port = 1194
    to_port =1194
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.vpn_sg.sg_id
}

resource "aws_security_group_rule" "vpn_alb"{
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = module.vpn_sg.sg_id
    security_group_id = module.alb_sg.sg_id
}

resource "aws_security_group_rule" "mysql_bastion"{
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.sg_id
    security_group_id = module.mysql_sg.sg_id
}
resource "aws_security_group_rule" "mysql_vpn"{
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.vpn_sg.sg_id
    security_group_id = module.mysql_sg.sg_id
}
resource "aws_security_group_rule" "backend_vpn"{
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.vpn_sg.sg_id
    security_group_id = module.backend_sg.sg_id
}
resource "aws_security_group_rule" "backend_vpn_http"{
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    source_security_group_id = module.vpn_sg.sg_id
    security_group_id = module.backend_sg.sg_id
}
resource "aws_security_group_rule" "backend_alb"{
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    source_security_group_id = module.alb_sg.sg_id
    security_group_id = module.backend_sg.sg_id
}
resource "aws_security_group_rule" "mysql_backend"{
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.backend_sg.sg_id
    security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "alb_frontend"{
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = module.frontend_sg.sg_id
    security_group_id = module.alb_sg.sg_id
}

resource "aws_security_group_rule" "web-alb_frontend"{
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = module.web_alb_sg.sg_id
    security_group_id = module.frontend_sg.sg_id
}

resource "aws_security_group_rule" "frontend"{
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.frontend_sg.sg_id
}