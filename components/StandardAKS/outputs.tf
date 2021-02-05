output "resource_group" {
  value = module.resource_group.name
}

# AKS
output "aks_client_key" {
  value = module.aks.client_key
}

output "aks_client_certificate" {
  value = module.aks.client_certificate
}

output "aks_cluster_ca_certificate" {
  value = module.aks.cluster_ca_certificate
}

output "aks_host" {
  value = module.aks.host
}

output "aks_username" {
  value = module.aks.username
}

output "aks_password" {
  value = module.aks.password
}

output "aks_node_resource_group" {
  value = module.aks.node_resource_group
}

output "aks_location" {
  value = module.aks.location
}

output "aks_id" {
  value = module.aks.aks_id
}

output "kube_config_raw" {
  value = module.aks.kube_config_raw
}

output "aks_admin_client_key" {
  value = module.aks.admin_client_key
}

output "aks_admin_client_certificate" {
  value = module.aks.admin_client_certificate
}

output "aks_admin_cluster_ca_certificate" {
  value = module.aks.admin_cluster_ca_certificate
}

output "aks_admin_host" {
  value = module.aks.admin_host
}

output "aks_admin_username" {
  value = module.aks.admin_username
}

output "aks_admin_password" {
  value = module.aks.admin_password
}

output "kube_admin_config_raw" {
  value = module.aks.kube_admin_config_raw
}

output "aks_http_application_routing_zone_name" {
  value = module.aks.http_application_routing_zone_name
}

output "aks_system_assigned_identity" {
  value = module.aks.system_assigned_identity
}

output "aks_ingress_nginx_external_ip" {
  value = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.ip
}

output "aks_public_ip_id" {
  value = module.aks_public_ips
}

output "aks_public_ip_fqdn" {
  value = module.aks_dns_name_get.stdout
}

output "aks_agentpool_principal_id" {
  value = module.aks_agentpool_principal_id.stdout
}

output "aks_configure" {
  value = module.aks.configure
}

# Storage Account
output "storage_account_name" {
  value = module.storage_account.storage_account_name
}
output "storage_account_primary_access_key" {
  value = module.storage_account.storage_account_primary_access_key
}

output "storage_account_shares" {
  value = module.storage_account.shares
}

# Key Vault
output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = module.key_vault.key_vault_id
}

output "key_vault_name" {
  description = "Name of key vault created."
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault, used for performing operations on keys and secrets."
  value       = module.key_vault.key_vault_uri
}

output "key_vault_secrets" {
  description = "A mapping of secret names and URIs."
  value       = module.key_vault.key_vault_secrets
}

output "Key_vault_references" {
  description = "A mapping of Key Vault references for App Service and Azure Functions."
  value       = module.key_vault.Key_vault_references
}
