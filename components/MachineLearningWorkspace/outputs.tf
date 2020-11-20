output "resource_group_name" {
  value = module.resource_group.name
}

output "machine_learning_workspace_id" {
  value = module.machine_learning_workspace.machine_learning_workspace_id
}

output "application_insights_id" {
  value = module.machine_learning_workspace.application_insights_id
}

output "key_vault_id" {
  value = module.machine_learning_workspace.key_vault_id
}

output "storage_account_id" {
  value = module.machine_learning_workspace.storage_account_id
}