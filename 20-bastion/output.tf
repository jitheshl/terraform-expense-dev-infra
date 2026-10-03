output "ec2-bastion" {
  value = aws_instance.bastion-instance.public_ip
  
}
