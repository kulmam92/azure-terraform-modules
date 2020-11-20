# Base code: https://github.com/aztfmod/terraform-azurerm-caf-virtual-network/tree/master/nsg
module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}

data "azurerm_resource_group" "main" {
  name       = var.resource_group_name
  depends_on = [var.resource_group_name]
}

resource "azurerm_network_security_group" "main" {
  for_each = var.subnets

  name                = var.name_override != "" ? join("-", [var.name_override, each.value.nsg_name_postfix]) : join("-", [module.naming.network_security_group.name, each.value.nsg_name_postfix])
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tags                = var.tags

  dynamic "security_rule" {
    for_each = lookup(each.value, "nsg", [])
    content {
      name                                       = lookup(security_rule.value, "name", null)
      priority                                   = lookup(security_rule.value, "priority", null)
      direction                                  = lookup(security_rule.value, "direction", null)
      access                                     = lookup(security_rule.value, "access", null)
      protocol                                   = lookup(security_rule.value, "protocol", null)
      source_port_range                          = lookup(security_rule.value, "source_port_range", null)
      source_port_ranges                         = lookup(security_rule.value, "source_port_ranges", null) == null ? [] : [lookup(security_rule.value, "source_port_ranges", null)]
      destination_port_range                     = lookup(security_rule.value, "destination_port_range", null)
      destination_port_ranges                    = lookup(security_rule.value, "destination_port_ranges", null) == null ? [] : [lookup(security_rule.value, "destination_port_ranges", null)]
      source_address_prefix                      = lookup(security_rule.value, "source_address_prefix", null)
      source_address_prefixes                    = lookup(security_rule.value, "source_address_prefixes", null) == null ? [] : [lookup(security_rule.value, "source_address_prefixes", null)]
      destination_address_prefix                 = lookup(security_rule.value, "destination_address_prefix", null)
      destination_address_prefixes               = lookup(security_rule.value, "destination_address_prefixes", null) == null ? [] : [lookup(security_rule.value, "destination_address_prefixes", null)]
      source_application_security_group_ids      = lookup(security_rule.value, "source_application_security_group_ids ", null) == null ? [] : [lookup(security_rule.value, "source_application_security_group_ids ", null)]
      destination_application_security_group_ids = lookup(security_rule.value, "destination_application_security_group_ids", null) == null ? [] : [lookup(security_rule.value, "destination_application_security_group_ids", null)]
    }
  }
}
