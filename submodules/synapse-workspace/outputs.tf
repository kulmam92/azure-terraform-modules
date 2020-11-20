output "azurerm_synapse_workspace_id" {
  description = "Id of azurerm synapse workspace."
  value       = azurerm_synapse_workspace.synapse.id
}

output "synapse_sql_admin_password" {
  description = "synapse sql_admin_password"
  sensitive   = true
  value       = random_password.synapse_sql_admin_password.result
}

output "managed_resource_group_name" {
  description = "Workspace managed resource group."
  value       = azurerm_synapse_workspace.synapse.managed_resource_group_name
}

output "connectivity_endpoints" {
  description = "A list of Connectivity endpoints for this Synapse Workspace."
  value       = azurerm_synapse_workspace.synapse.connectivity_endpoints
}

output "managed_service_identity" {
  description = "Managed Service Identity information for this Synapse Workspace."
  value       = azurerm_synapse_workspace.synapse.identity
}

output "storage_data_lake_gen2_filesystem_id" {
  description = "Managed Service Identity information for this Synapse Workspace."
  value       = azurerm_storage_data_lake_gen2_filesystem.synapse.id
}

output "synapse_sql_pool_id" {
  description = "Map of authorization keys with their ids."
  value       = { for a in azurerm_synapse_sql_pool.synapse : a.name => a.id }
}

output "role_assignments" {
  description = "A map of all applied role assignments."
  value       = module.azurerm_synapse_role_assignment.role_assignments
}

output "private_dns_zone_ids" {
  description = "Map of Private dns zones and their ids."
  value       = module.private_endpoint.private_dns_zone_ids
}

output "private_endpoint_ids" {
  description = "Map of Private endpoints and their ids."
  value       = module.private_endpoint.private_endpoint_ids
}
