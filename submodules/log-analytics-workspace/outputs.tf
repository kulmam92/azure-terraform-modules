output "id" {
  description = "The ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.main.id
}

output "primary_shared_key" {
  description = "The primary shared key for the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "secondary_shared_key" {
  description = "The secondary shared key for the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.main.secondary_shared_key
  sensitive   = true
}

output "workspace_id" {
  description = "The workspace (or customer) ID for the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.main.workspace_id
}

output "portal_url" {
  description = "The portal URL for the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.main.portal_url
}
