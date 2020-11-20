module "naming" {
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}

module "resource_group" {
  source = "../../submodules/resource-group"

  location           = var.location
  tags               = var.tags
  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}

module "vnet" {
  source = "../../submodules/vnet-network-security-group"

  resource_group_name = module.resource_group.name
  tags                = var.tags
  networking_object   = var.networking_object
  ddos_id             = var.ddos_id
  account_short_name  = var.account_short_name
  component           = var.component
  environment         = var.environment
  datacenter          = var.datacenter
  product             = var.product
}

module "routetable" {
  source = "../../submodules/routetable"

  resource_group_name          = module.resource_group.name
  tags                         = var.tags
  route_prefixes               = var.route_prefixes
  route_nexthop_types          = var.route_nexthop_types
  route_next_hop_in_ip_address = var.route_next_hop_in_ip_address
  route_names                  = var.route_names
  account_short_name           = var.account_short_name
  component                    = var.component
  environment                  = var.environment
  datacenter                   = var.datacenter
  product                      = var.product
}

resource "azurerm_subnet_route_table_association" "main" {
  count          = length(module.vnet.vnet_subnet_ids)
  subnet_id      = module.vnet.vnet_subnet_ids[count.index]
  route_table_id = module.routetable.routetable_id
}
