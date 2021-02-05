output "vnet_resource_group" {
  value = module.vnet_resource_group.name
}

output "vnet_name" {
  value = module.vnet.vnet_name
}

output "vnet_subnet_names" {
  value = module.vnet.vnet_subnet_names
}

# aks
output "aks_resource_group" {
  value = module.aks.resource_group
}

output "aks_client_key" {
  value = module.aks.aks_client_key
}

output "aks_client_certificate" {
  value = module.aks.aks_client_certificate
}

output "aks_cluster_ca_certificate" {
  value = module.aks.aks_cluster_ca_certificate
}

output "aks_host" {
  value = module.aks.aks_host
}

output "aks_username" {
  value = module.aks.aks_username
}

output "aks_password" {
  value = module.aks.aks_password
}

output "aks_node_resource_group" {
  value = module.aks.aks_node_resource_group
}

output "aks_location" {
  value = module.aks.aks_location
}

output "aks_id" {
  value = module.aks.aks_id
}

output "kube_config_raw" {
  value = module.aks.kube_config_raw
}

output "aks_admin_client_key" {
  value = module.aks.aks_admin_client_key
}

output "aks_admin_client_certificate" {
  value = module.aks.aks_admin_client_certificate
}

output "aks_admin_cluster_ca_certificate" {
  value = module.aks.aks_admin_cluster_ca_certificate
}

output "aks_admin_host" {
  value = module.aks.aks_admin_host
}

output "aks_admin_username" {
  value = module.aks.aks_admin_username
}

output "aks_admin_password" {
  value = module.aks.aks_admin_password
}

output "kube_admin_config_raw" {
  value = module.aks.kube_admin_config_raw
}

output "aks_http_application_routing_zone_name" {
  value = module.aks.aks_http_application_routing_zone_name
}

output "aks_system_assigned_identity" {
  value = module.aks.aks_system_assigned_identity
}

output "aks_public_ip_id" {
  value = module.aks.aks_public_ip_id
}

output "aks_public_ip_fqdn" {
  value = module.aks.aks_public_ip_fqdn
}

output "aks_agentpool_principal_id" {
  value = module.aks.aks_agentpool_principal_id
}

output "aks_configure" {
  value = module.aks.aks_configure
}

# storage account
output "storage_account_name" {
  value = module.aks.storage_account_name
}
output "storage_account_primary_access_key" {
  value = module.aks.storage_account_primary_access_key
}

output "storage_account_shares" {
  value = module.aks.storage_account_shares
}

# key vault
output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = module.aks.key_vault_id
}

output "key_vault_name" {
  description = "Name of key vault created."
  value       = module.aks.key_vault_name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault, used for performing operations on keys and secrets."
  value       = module.aks.key_vault_uri
}

output "key_vault_secrets" {
  description = "A mapping of secret names and URIs."
  value       = module.aks.key_vault_secrets
}

output "Key_vault_references" {
  description = "A mapping of Key Vault references for App Service and Azure Functions."
  value       = module.aks.Key_vault_references
}
