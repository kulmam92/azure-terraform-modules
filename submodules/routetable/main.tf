module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}

data "azurerm_resource_group" "main" {
  name       = var.resource_group_name
  depends_on = [var.resource_group_name]
}

resource "azurerm_route_table" "rtable" {
  name                          = var.name_override != "" ? var.name_override : module.naming.route_table.name
  location                      = data.azurerm_resource_group.main.location
  resource_group_name           = data.azurerm_resource_group.main.name
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
}

resource "azurerm_route" "route" {
  count = length(var.route_names)

  name                   = var.route_names[count.index]
  resource_group_name    = data.azurerm_resource_group.main.name
  route_table_name       = azurerm_route_table.rtable.name
  address_prefix         = var.route_prefixes[count.index]
  next_hop_type          = var.route_nexthop_types[count.index]
  next_hop_in_ip_address = var.route_next_hop_in_ip_address[count.index]
}
