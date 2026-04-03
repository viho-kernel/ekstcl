output "public_ip" {
  value = aws_eip.docker_ip.public_ip
}
