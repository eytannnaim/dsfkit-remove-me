
output "hub_key_pair" {
    value = aws_key_pair.hub_ssh_keypair.key_name
}

output "public_eip" {
    value = module.sonar_base_instance.instance_eip
}