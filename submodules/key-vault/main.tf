# Base code: https://github.com/innovationnorway/terraform-azurerm-key-vault
module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.component), lower(var.environment)]
}

data "azuread_group" "main" {
  count = length(local.group_names)
  name  = local.group_names[count.index]
}

data "azuread_user" "main" {
  count               = length(local.user_principal_names)
  user_principal_name = local.user_principal_names[count.index]
}

data "azurerm_client_config" "main" {}

data "azurerm_resource_group" "main" {
  name       = var.resource_group_name
  depends_on = [var.resource_group_name]
}

resource "azurerm_key_vault" "main" {
  name                = module.naming.key_vault.name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.main.tenant_id

  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
  soft_delete_enabled         = true

  sku_name = var.sku_name

  dynamic "access_policy" {
    for_each = local.combined_access_policies

    content {
      tenant_id = data.azurerm_client_config.main.tenant_id
      object_id = access_policy.value.object_id

      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }

  dynamic "access_policy" {
    for_each = local.service_principal_object_id != "" ? [local.self_permissions] : []

    content {
      tenant_id = data.azurerm_client_config.main.tenant_id
      object_id = access_policy.value.object_id

      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : list(var.network_acls)
    iterator = acl
    content {
      bypass                     = coalesce(acl.value.bypass, "None")
      default_action             = coalesce(acl.value.default_action, "Deny")
      ip_rules                   = acl.value.ip_rules
      virtual_network_subnet_ids = acl.value.virtual_network_subnet_ids
    }
  }

  tags = var.tags
}

resource "azurerm_key_vault_secret" "main" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.main.id
}
