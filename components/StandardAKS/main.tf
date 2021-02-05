locals {
  default_vault_secret = {
    MINIO-STORAGE-CRED    = "{accesskey: ${module.storage_account.storage_account_name}, secretkey: ${module.storage_account.storage_account_primary_access_key}}"
    PROMETHEUS-BASIC-AUTH = var.aks_prometheus_basic_auth
  }
}

module "resource_group" {
  source = "../../submodules/resource-group"

  location = var.location
  tags     = var.tags

  name_override      = var.resource_group_name_override
  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}

module "storage_account" {
  source = "../../submodules/storage-account"

  resource_group_name = module.resource_group.name
  tags                = var.tags

  name_override            = var.storage_account_name_override
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = var.storage_account_kind
  is_hns_enabled           = var.storage_account_is_hns_enabled
  network_rules            = var.storage_account_network_rules
  shares                   = var.storage_account_shares

  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}

module "key_vault" {
  source = "../../submodules/key-vault"

  resource_group_name = module.resource_group.name
  tags                = var.tags

  name_override             = var.key_vault_name_override
  sku_name                  = var.key_vault_sku_name
  enable_rbac_authorization = var.key_vault_enable_rbac_authorization
  access_policies           = var.key_vault_access_policies
  secrets                   = merge(local.default_vault_secret, var.key_vault_secrets)
  network_acls              = var.key_vault_network_acls
  role_assignments          = var.key_vault_role_assignments

  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}

module "aks" {
  source = "../../submodules/aks-cluster"

  resource_group_name = module.resource_group.name
  tags                = var.tags

  name_override                   = var.aks_name_override
  dns_prefix                      = var.aks_dns_prefix
  sku_tier                        = var.aks_sku_tier
  kubernetes_version              = var.aks_kubernetes_version
  private_cluster_enabled         = var.aks_private_cluster_enabled
  api_server_authorized_ip_ranges = var.aks_api_server_authorized_ip_ranges
  node_resource_group             = var.aks_node_resource_group
  linux_profile                   = var.aks_linux_profile
  windows_profile                 = var.aks_windows_profile
  agent_pools                     = var.aks_agent_pools
  # need a subnet for agent_pool
  agent_pool_subnet_name              = var.aks_agent_pool_subnet_name
  agent_pool_vnet_name                = var.aks_agent_pool_vnet_name
  agent_pool_vnet_resource_group_name = var.aks_agent_pool_vnet_resource_group_name
  service_principal                   = var.aks_service_principal
  addons                              = var.aks_addons
  network_profile                     = var.aks_network_profile
  enable_role_based_access_control    = var.aks_enable_role_based_access_control
  rbac_aad_managed                    = var.aks_rbac_aad_managed
  rbac_aad_admin_group_names          = var.aks_rbac_aad_admin_group_names
  rbac_azure_active_directory         = var.aks_rbac_azure_active_directory
  admins                              = var.aks_admins
  service_accounts                    = var.aks_service_accounts
  diagnostics                         = var.aks_diagnostics
  log_analytics_workspace_sku         = var.aks_log_analytics_workspace_sku
  log_retention_in_days               = var.aks_log_retention_in_days
  enable_log_analytics_workspace      = var.aks_enable_log_analytics_workspace
  container_registries                = var.aks_container_registries
  storage_contributor                 = var.aks_storage_contributor
  managed_identities                  = var.aks_managed_identities

  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product

  depends_on = [module.key_vault, module.storage_account]
}
