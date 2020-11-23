module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}

data "azurerm_resource_group" "main" {
  name       = var.resource_group_name
  depends_on = [var.resource_group_name]
}

data "azurerm_subnet" "main" {
  for_each = var.private_endpoints

  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.vnet_resource_group_name
}

# create private endpoint
# https://github.com/terraform-providers/terraform-provider-azurerm/issues/7726
resource "azurerm_private_dns_zone" "main" {
  # private_dns_zone_name is optional
  for_each = {
    for k, r in var.private_endpoints : k => r
    if contains(keys(r), "private_dns_zone_name")
  }

  name                = each.value.private_dns_zone_name
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_private_endpoint" "main" {
  for_each = var.private_endpoints

  name                = join("-", [module.naming.private_endpoint.name, each.value.private_endpoint_name_postfix])
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = data.azurerm_subnet.main[each.key].id

  dynamic "private_dns_zone_group" {
    for_each = {
      for k, r in azurerm_private_dns_zone.main : k => r
      if k == each.key
    }
    iterator = dnszoneid
    content {
      name                 = join("-", [module.naming.private_dns_zone_group.name, each.value.private_endpoint_name_postfix])
      private_dns_zone_ids = [dnszoneid.value.id]
    }
  }

  private_service_connection {
    name                           = join("-", [module.naming.private_service_connection.name, each.value.private_endpoint_name_postfix])
    is_manual_connection           = false
    private_connection_resource_id = var.private_connection_resource_id
    # https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
    subresource_names = each.value.subresource_names
  }
  tags = var.tags
}
