module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}

# This module is used to provide ownership for a resource group that
# other modules can place their resources into without conflicting
# with each other. The default resource group name can be overridden
# by passing an argument to the `name_override` variable.
resource "azurerm_resource_group" "main" {
  name     = var.name_override != "" ? var.name_override : module.naming.resource_group.name
  location = var.location
  tags     = var.tags
}
