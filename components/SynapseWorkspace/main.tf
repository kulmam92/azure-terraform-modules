module "resource_group" {
  source = "../../submodules/resource-group"

  location           = var.location
  tags               = var.tags
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

  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = var.storage_account_kind
  is_hns_enabled           = var.storage_account_is_hns_enabled
  network_rules            = var.storage_account_network_rules
  account_short_name       = var.account_short_name
  component                = var.component
  environment              = var.environment
  datacenter               = var.datacenter
  product                  = var.product
}

module "synapse" {
  source = "../../submodules/synapse-workspace"

  resource_group_name = module.resource_group.name
  tags                = var.tags

  sql_admin_password                  = var.sql_admin_password
  sql_admin_username                  = var.sql_admin_username
  aad_admin_login                     = var.aad_admin_login
  aad_admin_type                      = var.aad_admin_type
  firewall_rules                      = var.firewall_rules
  private_endpoints                   = var.private_endpoints
  storage_account_name                = module.storage_account.storage_account_name
  storage_account_resource_group_name = module.resource_group.name
  synapse_sql_pool_object             = var.synapse_sql_pool_object
  role_assignments                    = var.role_assignments

  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}

