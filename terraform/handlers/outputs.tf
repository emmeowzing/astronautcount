output "public-eip" {
  value = aws_eip.static.public_ip
}

output "public-fqdn" {
  value = aws_eip.static.public_dns
}
