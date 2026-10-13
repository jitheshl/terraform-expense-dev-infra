locals {
  db_name = "${var.project_name}-${var.environment}-db"
  mysql_sg_id = data.aws_ssm_parameter.mysql_sg_id.value
  database_subnet_group_name = data.aws_ssm_parameter.database-subnet-group.value
}
