resource "random_id" "randomize" {
  byte_length = 8
}

module "vnet_resource_group" {
  source = "../../../../submodules/resource-group"

  name_override      = join("-", ["rg", random_id.randomize.hex, "vn"])
  location           = var.location
  tags               = var.tags
  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}

# need a subnet for agent_pool
module "vnet" {
  source = "../../../../submodules/vnet-network-security-group"

  name_override       = join("-", ["vn", random_id.randomize.hex])
  resource_group_name = module.vnet_resource_group.name
  tags                = var.tags
  networking_object   = var.vnet_networking_object
  ddos_id             = var.vnet_ddos_id
  account_short_name  = var.account_short_name
  component           = var.component
  environment         = var.environment
  datacenter          = var.datacenter
  product             = var.product
}

module "aks" {
  source = "../../"

  location                     = var.location
  resource_group_name_override = join("-", ["rg", random_id.randomize.hex, "k8s"])
  tags                         = var.tags

  # AKS
  aks_name_override                       = join("-", ["aks", random_id.randomize.hex])
  aks_dns_prefix                          = var.aks_dns_prefix
  aks_sku_tier                            = var.aks_sku_tier
  aks_kubernetes_version                  = var.aks_kubernetes_version
  aks_private_cluster_enabled             = var.aks_private_cluster_enabled
  aks_api_server_authorized_ip_ranges     = var.aks_api_server_authorized_ip_ranges
  aks_node_resource_group                 = var.aks_node_resource_group
  aks_linux_profile                       = var.aks_linux_profile
  aks_windows_profile                     = var.aks_windows_profile
  aks_agent_pools                         = var.aks_agent_pools
  aks_agent_pool_subnet_name              = module.vnet.vnet_subnet_names[0]
  aks_agent_pool_vnet_name                = module.vnet.vnet_name
  aks_agent_pool_vnet_resource_group_name = module.vnet_resource_group.name
  aks_service_principal                   = var.aks_service_principal
  aks_addons                              = var.aks_addons
  aks_network_profile                     = var.aks_network_profile
  aks_enable_role_based_access_control    = var.aks_enable_role_based_access_control
  aks_rbac_aad_managed                    = var.aks_rbac_aad_managed
  aks_rbac_aad_admin_group_names          = var.aks_rbac_aad_admin_group_names
  aks_rbac_azure_active_directory         = var.aks_rbac_azure_active_directory
  aks_admins                              = var.aks_admins
  aks_service_accounts                    = var.aks_service_accounts
  aks_diagnostics                         = var.aks_diagnostics
  aks_log_analytics_workspace_sku         = var.aks_log_analytics_workspace_sku
  aks_log_retention_in_days               = var.aks_log_retention_in_days
  aks_enable_log_analytics_workspace      = var.aks_enable_log_analytics_workspace
  aks_container_registries                = var.aks_container_registries
  aks_storage_contributor                 = var.aks_storage_contributor
  aks_managed_identities                  = var.aks_managed_identities
  aks_cert_manager_acme_email             = var.aks_cert_manager_acme_email
  aks_prometheus_basic_auth               = var.aks_prometheus_basic_auth

  # storage account
  storage_account_name_override    = var.storage_account_name_override
  storage_account_tier             = var.storage_account_tier
  storage_account_replication_type = var.storage_account_replication_type
  storage_account_kind             = var.storage_account_kind
  storage_account_is_hns_enabled   = var.storage_account_is_hns_enabled
  storage_account_network_rules    = var.storage_account_network_rules
  storage_account_shares           = var.storage_account_shares

  # key vault
  key_vault_name_override             = join("-", ["kv", random_id.randomize.hex])
  key_vault_sku_name                  = var.key_vault_sku_name
  key_vault_enable_rbac_authorization = var.key_vault_enable_rbac_authorization
  key_vault_access_policies           = var.key_vault_access_policies
  key_vault_secrets                   = var.key_vault_secrets
  key_vault_network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.key_vault_network_acls_ip_rules
    virtual_network_subnet_ids = [module.vnet.vnet_subnet_ids[0]]
  }
  key_vault_role_assignments = var.key_vault_role_assignments

  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product

  depends_on = [module.vnet, module.vnet_resource_group]
}
