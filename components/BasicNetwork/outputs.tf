output "resource_group_name" {
  value = module.resource_group.name
}

output "vnet_name" {
  value = module.vnet.vnet_name
}

output "subnet_ids" {
  value = module.vnet.vnet_subnet_ids
}

output "subnet_ids_map" {
  value = module.vnet.vnet_subnet_ids_map
}

output "network_security_group_ids" {
  value = module.vnet.vnet_nsg_ids
}

output "network_security_group_ids_map" {
  value = module.vnet.vnet_nsg_ids_map
}

output "routetable_id" {
  value = module.routetable.routetable_id
}
