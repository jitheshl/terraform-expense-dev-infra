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
    data "aws_ssm_parameter" "bastion_sg_id"{
       name = "/${var.project_name}/${var.environment}/bastion_sg_id"
    }

    data "aws_ssm_parameter" "public-subnet-id"{
       name = "/${var.project_name}/${var.environment}/public-subnet-id"
    }