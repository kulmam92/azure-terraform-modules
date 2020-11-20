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

module "eventhub" {
  source = "../../submodules/eventhub-shared"

  resource_group_name = module.resource_group.name
  tags                = var.tags

  sku                 = var.eventhub_sku
  capacity            = var.eventhub_capacity
  auto_inflate        = var.eventhub_auto_inflate
  diagnostics         = var.eventhub_diagnostics
  network_rules       = var.eventhub_network_rules
  private_endpoints   = var.eventhub_private_endpoints
  authorization_rules = var.eventhub_authorization_rules
  hubs                = var.eventhub_hubs

  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}

module "eventhub_role_assignment" {
  source = "../../submodules/role-assignment"

  scope            = module.eventhub.namespace_id
  role_assignments = var.eventhub_role_assignments
}
