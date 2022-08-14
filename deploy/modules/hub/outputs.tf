output "hub_key_pair" {
  value = aws_key_pair.hub_ssh_keypair.key_name
}

output "public_eip" {
  value = module.hub_instance.instance_eip
}

output "federation_public_key" {
  value = data.local_file.dsf_hub_public_ssh_federation_key.content
}
