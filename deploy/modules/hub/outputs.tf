output "public_eip" {
  value = module.hub_instance.instance_eip
}

output "federation_public_key" {
  value = resource.tls_private_key.dsf_hub_ssh_federation_key.public_key_openssh
}
