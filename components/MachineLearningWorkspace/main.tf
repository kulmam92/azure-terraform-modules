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

module "machine_learning_workspace" {
  source = "../../submodules/machine-learning-workspace"

  resource_group_name                 = module.resource_group.name
  tags                                = var.tags
  storage_account_replication_type    = var.storage_account_replication_type
  storage_account_network_rules       = var.storage_account_network_rules
  key_vault_sku_name                  = var.key_vault_sku_name
  key_vault_access_policies           = var.key_vault_access_policies
  key_vault_secrets                   = var.key_vault_secrets
  key_vault_network_acls              = var.key_vault_network_acls
  machine_learning_workspace_sku_name = var.machine_learning_workspace_sku_name
  compute_instance_names              = var.compute_instance_names
  compute_cluster_names               = var.compute_cluster_names
  vnet_resource_group_name            = var.vnet_resource_group_name
  vnet_name                           = var.vnet_name
  subnet_name                         = var.subnet_name
  account_short_name                  = var.account_short_name
  component                           = var.component
  environment                         = var.environment
  datacenter                          = var.datacenter
  product                             = var.product
}

module "machine_learning_workspace_role_assignment" {
  source = "../../submodules/role-assignment"

  scope            = module.machine_learning_workspace.machine_learning_workspace_id
  role_assignments = var.machine_learning_workspace_role_assignments
}
