output "hub_key_pair" {
    value = module.hub.hub_key_pair
}

output "dsf_hub_eip" {
    value = module.hub.public_eip
}

output "dsf_gw_eip" {
    value = module.agentless-gw.public_eip
}

