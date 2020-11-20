# Base code: https://github.com/Azure/terraform-azurerm-vnet
#Azure Generic vNet Module
module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}

data "azurerm_resource_group" "main" {
  name       = var.resource_group_name
  depends_on = [var.resource_group_name]
}

resource "azurerm_virtual_network" "main" {
  name                = module.naming.virtual_network.name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = [var.address_space]
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "main" {
  count                = length(var.subnet_names)
  name                 = join("-", [module.naming.subnet.name, var.subnet_names[count.index]])
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_resource_group.main.name
  address_prefixes     = [var.subnet_prefixes[count.index]]
}
