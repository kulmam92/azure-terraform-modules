output "network_security_group_ids" {
  value = [for b in azurerm_network_security_group.main : b.id]
}

output "network_security_group_names" {
  value = [for b in azurerm_network_security_group.main : b.name]
}

output "network_security_group_ids_map" {
  value = azurerm_network_security_group.main
}
