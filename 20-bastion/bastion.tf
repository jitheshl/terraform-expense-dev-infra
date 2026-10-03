resource "aws_instance" "bastion-instance" {
  ami                    = data.aws_ami.ami_id.id
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id = local.public_subnet_id[0]
  tags = merge(
    var.common_tags,{
      Name = "${var.project_name}-${var.environment}-bastion"
    }
  )
}





