output "vnet_id" {
  description = "The id of the newly created vNet"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "The Name of the newly created vNet"
  value       = azurerm_virtual_network.main.name
}

output "vnet_location" {
  description = "The location of the newly created vNet"
  value       = azurerm_virtual_network.main.location
}

output "vnet_address_space" {
  description = "The address space of the newly created vNet"
  value       = azurerm_virtual_network.main.address_space
}

output "vnet_subnet_ids" {
  description = "The ids of subnets created inside the newl vNet"
  value       = module.subnets.subnet_ids
}

output "vnet_subnet_names" {
  description = "The names of subnets created inside the newl vNet"
  value       = module.subnets.subnet_names
}

output "vnet_subnet_ids_map" {
  description = "The object map of subnets created inside the newl vNet"
  value       = module.subnets.subnet_ids_map
}

output "vnet_nsg_ids" {
  description = "The ids of network security groups map to subnets"
  value       = module.network_security_group.network_security_group_ids
}

output "vnet_nsg_ids_map" {
  description = "The object map of network security groups map to subnets"
  value       = module.network_security_group.network_security_group_ids_map
}

output "vent_nsg_names" {
  value = module.network_security_group.network_security_group_names
}
