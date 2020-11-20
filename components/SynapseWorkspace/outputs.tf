output "resource_group_name" {
  value = module.resource_group.name
}

output "storage_account_id" {
  value = module.storage_account.storage_account_id
}

output "azurerm_synapse_workspace_id" {
  description = "Id of azurerm synapse workspace."
  value       = module.synapse.azurerm_synapse_workspace_id
}

output "synapse_sql_admin_password" {
  description = "synapse sql_admin_password"
  sensitive   = true
  value       = module.synapse.synapse_sql_admin_password
}

output "managed_resource_group_name" {
  description = "Workspace managed resource group."
  value       = module.synapse.managed_resource_group_name
}

output "connectivity_endpoints" {
  description = "A list of Connectivity endpoints for this Synapse Workspace."
  value       = module.synapse.connectivity_endpoints
}

output "managed_service_identity" {
  description = "Managed Service Identity information for this Synapse Workspace."
  value       = module.synapse.managed_service_identity
}

output "storage_data_lake_gen2_filesystem_id" {
  description = "Managed Service Identity information for this Synapse Workspace."
  value       = module.synapse.storage_data_lake_gen2_filesystem_id
}

output "synapse_sql_pool_id" {
  description = "Map of authorization keys with their ids."
  value       = module.synapse.synapse_sql_pool_id
}

output "role_assignments" {
  description = "A map of all applied role assignments."
  value       = module.synapse.role_assignments
}

output "private_dns_zone_ids" {
  description = "Map of Private dns zones and their ids."
  value       = module.synapse.private_dns_zone_ids
}

output "private_endpoint_ids" {
  description = "Map of Private endpoints and their ids."
  value       = module.synapse.private_endpoint_ids
}