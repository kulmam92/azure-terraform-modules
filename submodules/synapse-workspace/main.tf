# Base code: N/A
locals {
  user_aad_admin = var.aad_admin_type == "user" ? { lower("${var.aad_admin_login}-${var.aad_admin_type}") : var.aad_admin_login } : {}

  group_aad_admin = var.aad_admin_type == "group" ? { lower("${var.aad_admin_login}-${var.aad_admin_type}") : var.aad_admin_login } : {}

  service_principal_aad_admin = var.aad_admin_type == "service_principal" ? { lower("${var.aad_admin_login}-${var.aad_admin_type}") : var.aad_admin_login } : {}
}

module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}

data "azurerm_resource_group" "synapse" {
  name       = var.resource_group_name
  depends_on = [var.resource_group_name]
}

data "azurerm_storage_account" "synapse" {
  name                = var.storage_account_name
  resource_group_name = var.storage_account_resource_group_name
  depends_on          = [var.storage_account_name]
}

data "azurerm_client_config" "synapse" {}

data "azuread_user" "aad_admin" {
  for_each = local.user_aad_admin

  user_principal_name = each.value
}

data "azuread_group" "aad_admin" {
  for_each = local.group_aad_admin

  name = each.value
}

data "azuread_service_principal" "aad_admin" {
  for_each = local.service_principal_aad_admin

  display_name = each.value
}

resource "random_password" "synapse_sql_admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "synapse" {
  name               = module.naming.storage_data_lake_gen2_filesystem.name
  storage_account_id = data.azurerm_storage_account.synapse.id
}

resource "azurerm_synapse_workspace" "synapse" {
  # name can contain only lowercase letters or numbers, and be between 1 and 45 characters long
  name                = var.name_override != "" ? var.name_override : join("", ["sw", module.naming.storage_account.name])
  resource_group_name = data.azurerm_resource_group.synapse.name
  location            = data.azurerm_resource_group.synapse.location
  tags                = var.tags

  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.synapse.id
  sql_administrator_login_password     = var.sql_admin_password != "" ? var.sql_admin_password : random_password.synapse_sql_admin_password.result
  sql_administrator_login              = var.sql_admin_username

  dynamic "aad_admin" {
    for_each = merge(data.azuread_user.aad_admin, data.azuread_group.aad_admin, data.azuread_service_principal.aad_admin)
    content {
      login     = var.aad_admin_login
      object_id = aad_admin.value.object_id
      tenant_id = data.azurerm_client_config.synapse.tenant_id
    }
  }
}

resource "azurerm_synapse_firewall_rule" "synapse" {
  # var.firewall_rules is a list, so we must now project it into a map
  # Each instance must have a unique key, so we'll construct one
  # by combining the vm_index, and lun.
  for_each = {
    for rule in var.firewall_rules : rule.name => rule
  }

  name                 = each.value.name
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  start_ip_address     = each.value.start_ip_address
  end_ip_address       = each.value.end_ip_address
}

# only create dedicated pool
# name can contain only letters, numbers or underscore, The value must be between 1 and 15 characters long
resource "azurerm_synapse_sql_pool" "synapse" {
  for_each = var.synapse_sql_pool_object

  name                 = join("_", ["ssp", each.value.name_postfix])
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  sku_name             = each.value.sku_name
  create_mode          = each.value.create_mode
  tags                 = var.tags
}

module "azurerm_synapse_role_assignment" {
  source = "../../submodules/synapse-role-assignment"

  resource_group_name    = var.resource_group_name
  synapse_workspace_name = var.name_override != "" ? var.name_override : join("", ["sw", module.naming.storage_account.name])
  role_assignments       = var.role_assignments

  depends_on = [azurerm_synapse_workspace.synapse]
}

# create private endpoint
module "private_endpoint" {
  source = "../../submodules/private-endpoint"

  resource_group_name = data.azurerm_resource_group.synapse.name
  tags                = var.tags

  private_connection_resource_id = azurerm_synapse_workspace.synapse.id
  private_endpoints              = var.private_endpoints

  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}
