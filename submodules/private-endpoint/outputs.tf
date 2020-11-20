output "private_dns_zone_ids" {
  description = "Map of Private dns zones and their ids."
  value       = { for k, v in azurerm_private_dns_zone.main : k => v.id }
}

output "private_endpoint_ids" {
  description = "Map of Private endpoints and their ids."
  value       = { for k, v in azurerm_private_endpoint.main : k => v.id }
}