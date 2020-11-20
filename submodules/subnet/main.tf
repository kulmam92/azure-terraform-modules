# Base code: https://github.com/aztfmod/terraform-azurerm-caf-virtual-network/tree/master/subnet
module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}

data "azurerm_resource_group" "main" {
  name       = var.resource_group_name
  depends_on = [var.resource_group_name]
}

data "azurerm_virtual_network" "main" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
  depends_on          = [var.virtual_network_name]
}

resource "azurerm_subnet" "main" {
  for_each = var.subnets

  name                                           = var.name_override != "" ? join("-", [var.name_override, each.value.name_postfix]) : join("-", [module.naming.subnet.name, each.value.name_postfix])
  resource_group_name                            = data.azurerm_resource_group.main.name
  virtual_network_name                           = data.azurerm_virtual_network.main.name
  address_prefixes                               = each.value.cidr
  service_endpoints                              = lookup(each.value, "service_endpoints", [])
  enforce_private_link_endpoint_network_policies = lookup(each.value, "enforce_private_link_endpoint_network_policies", null)
  enforce_private_link_service_network_policies  = lookup(each.value, "enforce_private_link_service_network_policies", null)

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", null) != null ? [1] : []

    content {
      name = lookup(each.value.delegation, "name", null)

      service_delegation {
        name    = lookup(each.value.delegation.service_delegation, "name", null)
        actions = lookup(each.value.delegation.service_delegation, "actions", null)
      }
    }
  }
}
