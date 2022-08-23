
output "public_ip" {
  description = "Public Elastic IP address of the DSF base instance"
  value       = module.gw_instance.public_ip
}

output "private_ip" {
  description = "Private IP address of the DSF base instance"
  value       = module.gw_instance.private_ip
}