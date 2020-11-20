output "subnet_ids" {
  description = "The ids of subnets created inside the new vNet"
  value       = [for b in azurerm_subnet.main : b.id]
}

output "subnet_names" {
  description = "The ids of subnets created inside the new vNet"
  value       = [for b in azurerm_subnet.main : b.name]
}

output "subnet_ids_map" {
  description = "The object map of subnets created inside the new vNet"
  value       = azurerm_subnet.main
}
