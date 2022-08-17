output "dsf_hub_eip" {
    value = module.hub.public_address
}

output "dsf_gw_eip" {
  value = [
    for gw in module.agentless_gw : gw.public_address
  ]
}

output "hub_web_console_url" {
    value     = join("", ["https://", module.hub.public_address, ":8443/" ])
}

output "hub_ssh_command" {
    value     = join("", ["ssh -i dsf_hub_ssh_key ec2-user@", module.hub.public_address])
}

