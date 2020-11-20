# Base code: https://github.com/scalair/terraform-azure-storage-account
# Terraform module which creates azure storage account with the ability to manage the following features:
# Lifecyle rules
# Network and firewall rules
# Cross-origin resource sharing

##################
# Downloaded and modified Azure/naming/azurerm to workaround the below error.
# Error: Module does not support count

#   on main.tf line 87, in module "storage_account":
#   87:   count  = var.qlik_storage_account == "true" ? 1 : 0

# Module "storage_account_qlik" cannot be used with count because it contains a
# nested provider configuration for "random", at
# .terraform/modules/storage_account_qlik.naming/main.tf:1,10-18.

# This module can be made compatible with count by changing it to receive all of
# its provider configurations from the calling module, by using the "providers"
# argument in the calling module block.
###################
module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}

data "azurerm_resource_group" "main" {
  name       = var.resource_group_name
  depends_on = [var.resource_group_name]
}

resource "azurerm_storage_account" "main" {
  name                      = var.name_override != "" ? var.name_override : module.naming.storage_account.name_unique
  resource_group_name       = data.azurerm_resource_group.main.name
  location                  = data.azurerm_resource_group.main.location
  account_kind              = var.account_kind
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  access_tier               = var.access_tier
  enable_https_traffic_only = var.https_traffic
  is_hns_enabled            = var.is_hns_enabled

  tags = var.tags

  dynamic network_rules {
    for_each = var.network_rules
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  dynamic blob_properties {
    for_each = var.blob_properties_cors_rules
    content {
      cors_rule {
        allowed_headers    = blob_properties.value.allowed_headers
        allowed_methods    = blob_properties.value.allowed_methods
        allowed_origins    = blob_properties.value.allowed_origins
        exposed_headers    = blob_properties.value.exposed_headers
        max_age_in_seconds = blob_properties.value.max_age_in_seconds
      }
    }
  }
}

resource "azurerm_storage_management_policy" "main" {
  count              = var.add_lifecycle_rules ? 1 : 0
  storage_account_id = azurerm_storage_account.main.id
  dynamic rule {
    for_each = var.lifcecycle_rules
    content {
      name    = rule.value.name
      enabled = rule.value.enabled
      filters {
        prefix_match = rule.value.prefix_match
        blob_types   = rule.value.blob_types
      }
      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = rule.value.tier_to_cool_after_days_since_modification_greater_than
          tier_to_archive_after_days_since_modification_greater_than = rule.value.tier_to_archive_after_days_since_modification_greater_than
          delete_after_days_since_modification_greater_than          = rule.value.delete_after_days_since_modification_greater_than
        }
        snapshot {
          delete_after_days_since_creation_greater_than = rule.value.delete_snapshot_after_days_since_creation_greater_than
        }
      }
    }
  }
}

resource "azurerm_storage_container" "main" {
  depends_on            = [azurerm_storage_account.main]
  count                 = length(var.containers)
  name                  = var.containers[count.index].name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = var.containers[count.index].access_type
}

resource "azurerm_storage_share" "main" {
  count                = length(var.shares)
  name                 = var.shares[count.index].name
  storage_account_name = azurerm_storage_account.main.name
  quota                = var.shares[count.index].quota
}
