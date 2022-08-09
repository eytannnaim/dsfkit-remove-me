output "hub_instance_public_ip" {
  description = "Public IP address of the DSF Hub"
  value       = aws_eip.dsf_hub_eip.public_ip
}

output "gw_instance_public_ip" {
  description = "Public IP address of the GW"
  value       = aws_eip.dsf_gw_eip.public_ip
}

output "hub_web_console_url" {
    value     = join("", ["https://", aws_eip.dsf_hub_eip.public_ip, ":8443/" ])
}

output "ssh_command" {
    value     = join("", ["ssh -i dsf_hub_ssh_key ec2-user@", aws_eip.dsf_hub_eip.public_ip])
}
