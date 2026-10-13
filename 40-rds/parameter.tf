resource "aws_ssm_parameter" "rds-endpoint"{
    name = "/${var.project_name}/${var.environment}/rds-endpoint"
    type = "String"
     value = split(":", module.db.db_instance_endpoint)[0]
}

