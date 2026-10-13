output "ec2-vpn" {
  value = aws_instance.vpn-instance.public_ip
  
}
