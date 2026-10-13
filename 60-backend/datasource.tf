data "aws_ami" "ami_id"{
    most_recent="true"
    owners=["973714476881"]

    filter{
        name = "name"
        values = ["Redhat-9-DevOps-Practice"]
    }
    filter{
        name = "root-device-type"
        values = ["ebs"]
    }
    filter{
        name = "virtualization-type"
        values = ["hvm"]
    }

}
data "aws_ssm_parameter" "backend_sg_id"{
    name = "/${var.project_name}/${var.environment}/backend_sg_id"
}

data "aws_ssm_parameter" "private-subnet-id"{
    name = "/${var.project_name}/${var.environment}/private-subnet-id"
}

    data "aws_ssm_parameter" "rds_endpoint"{
    name = "/${var.project_name}/${var.environment}/rds-endpoint"
}

data "aws_ssm_parameter" "vpc_id"{
       name = "/${var.project_name}/${var.environment}/vpc_id"
}
data "aws_ssm_parameter" "alb_listener_arn"{
       name  = "/${var.project_name}/${var.environment}/alb_listener_arn"
}