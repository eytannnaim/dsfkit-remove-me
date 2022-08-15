output "public_eip" {
  value = module.hub_instance.instance_eip
}

output "federation_public_key" {
  value = data.local_file.dsf_hub_public_ssh_federation_key.content
}
