output "instance_public_ip" {
  description = "Public IP address of the DSF Hub"
  value       = aws_eip.dsf_hub_eip.public_ip
}

output "hub_url" {
    value     = join("", ["https://", aws_eip.dsf_hub_eip.public_ip, ":8443/" ])
}

output "ssh_command" {
    value     = join("", ["ssh  -i <key-path> ec2-user@", aws_eip.dsf_hub_eip.public_ip])
}