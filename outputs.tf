
output "ec2_public_ip" {
  value = aws_instance.dev-server.public_ip

}
