output "public_address" {
  value = module.hub_instance.public_address
}

output "private_address" {
  value = module.hub_instance.private_address
}

output "federation_public_key" {
  value = resource.tls_private_key.dsf_hub_ssh_federation_key.public_key_openssh
}
