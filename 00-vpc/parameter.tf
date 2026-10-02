resource "aws_ssm_parameter" "vpc_id"{
    name = "/${var.project_name}/${var.environment}/vpc_id"
    type = "String"
    value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "public-subnet-id"{
    name = "/${var.project_name}/${var.environment}/public-subnet-id"
    type = "StringList"
    value = join(",",module.vpc.aws-public-subnet)
}
resource "aws_ssm_parameter" "private-subnet-id"{
    name = "/${var.project_name}/${var.environment}/private-subnet-id"
    type = "StringList"
    value = join(",",module.vpc.aws-private-subnet)
}
resource "aws_ssm_parameter" "database-subnet-id"{
    name = "/${var.project_name}/${var.environment}/database-subnet-id"
    type = "StringList"
    value = join(",",module.vpc.aws-database-subnet)
}