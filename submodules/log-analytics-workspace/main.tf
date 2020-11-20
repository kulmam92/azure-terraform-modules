module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.component), lower(var.environment), lower(var.datacenter)]
}

data "azurerm_resource_group" "main" {
  name       = var.resource_group_name
  depends_on = [var.resource_group_name]
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = module.naming.log_analytics_workspace.name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  retention_in_days   = var.retention_in_days
  sku                 = var.sku
  tags                = var.tags
}
