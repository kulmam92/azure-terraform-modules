# Azure vNet, Subnet, NSG and mapping of subnet and NSG
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
  name                = var.name_override != "" ? var.name_override : module.naming.virtual_network.name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = var.networking_object.vnet.address_space
  tags                = var.tags

  dns_servers = lookup(var.networking_object.vnet, "dns", null)

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_id != "" ? [1] : []

    content {
      id     = var.ddos_id
      enable = true
    }
  }
}

module "subnets" {
  source = "../../submodules/subnet"

  name_override        = var.name_override != "" ? var.name_override : module.naming.subnet.name
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  subnets              = var.networking_object.subnets
  tags                 = var.tags
  account_short_name   = var.account_short_name
  component            = var.component
  environment          = var.environment
  datacenter           = var.datacenter
  product              = var.product
}

module "network_security_group" {
  source = "../../submodules/network-security-group"

  name_override       = var.name_override != "" ? var.name_override : module.naming.network_security_group.name
  resource_group_name = data.azurerm_resource_group.main.name
  # virtual_network_name    = azurerm_virtual_network.main.name
  subnets            = var.networking_object.subnets
  tags               = var.tags
  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}

resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = module.subnets.subnet_ids_map

  subnet_id                 = module.subnets.subnet_ids_map[each.key].id
  network_security_group_id = module.network_security_group.network_security_group_ids_map[each.key].id
}
