output "machine_learning_workspace_id" {
  value       = azurerm_machine_learning_workspace.main.id
}

output "application_insights_id" {
  value       = azurerm_application_insights.main.id
}

output "key_vault_id" {
  value       = module.key_vault.id
}

output "storage_account_id" {
  value       = module.storage_account.storage_account_id
}