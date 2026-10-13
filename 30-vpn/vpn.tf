resource "aws_key_pair" "open-vpn" {
  key_name   = "open-vpn"
  public_key = file("D:/..Devops/open-vpn1.pub")
}

resource "aws_instance" "vpn-instance" {
  ami                    = "ami-0659b21ac22689f17"
  key_name               = aws_key_pair.open-vpn.key_name
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  instance_type          = "t3.micro"
  user_data              = file("user-data.sh")
  subnet_id              = local.public_subnet_id[0]

  tags = merge(
    var.common_tags, {
      Name = "${var.project_name}-${var.environment}-vpn"
    }
  )
}

output "vpn_id" {
  value       = aws_instance.vpn-instance.public_ip
}
