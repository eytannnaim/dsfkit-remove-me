output "public_address" {
  description = "Public Elastic IP address of the DSF base instance"
  value       = aws_eip.dsf_instance_eip.public_ip
}

output "private_address" {
  description = "Private IP address of the DSF base instance"
  value       = aws_instance.dsf_base_instance.private_dns
}
