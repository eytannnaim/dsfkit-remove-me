output "instance_eip" {
  description = "Public Elastic IP address of the DSF base instance"
  value       = aws_eip.dsf_instance_eip.public_ip
}
