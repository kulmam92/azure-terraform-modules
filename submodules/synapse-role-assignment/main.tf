locals {
  # Converting `role_assignments` from a list of objects into three separate
  # maps that can be consumed by for_each. The keys are a combination of name,
  # role and type to ensure no duplicates are created.
  user_role_assignments = {
    for ra in var.role_assignments : lower("${ra.name}-${ra.role}-${ra.type}") => ra if ra.type == "user"
  }

  group_role_assignments = {
    for ra in var.role_assignments : lower("${ra.name}-${ra.role}-${ra.type}") => ra if ra.type == "group"
  }

  service_principal_role_assignments = {
    for ra in var.role_assignments : lower("${ra.name}-${ra.role}-${ra.type}") => ra if ra.type == "service_principal"
  }
}

data "azuread_user" "main" {
  for_each = local.user_role_assignments

  user_principal_name = each.value.name
}

data "azuread_group" "main" {
  for_each = local.group_role_assignments

  name = each.value.name
}

data "azuread_service_principal" "main" {
  for_each = local.service_principal_role_assignments

  display_name = each.value.name
}

data "azurerm_synapse_workspace" "main" {
  name                = var.synapse_workspace_name
  resource_group_name = var.resource_group_name
  depends_on          = [var.resource_group_name, var.synapse_workspace_name]
}

resource "azurerm_synapse_role_assignment" "user" {
  for_each = local.user_role_assignments

  synapse_workspace_id = data.azurerm_synapse_workspace.main.id
  role_name            = each.value.role
  principal_id         = data.azuread_user.main[each.key].id
}

resource "azurerm_synapse_role_assignment" "group" {
  for_each = local.group_role_assignments

  synapse_workspace_id = data.azurerm_synapse_workspace.main.id
  role_name            = each.value.role
  principal_id         = data.azuread_group.main[each.key].id
}

resource "azurerm_synapse_role_assignment" "service_principal" {
  for_each = local.service_principal_role_assignments

  synapse_workspace_id = data.azurerm_synapse_workspace.main.id
  role_name            = each.value.role
  principal_id         = data.azuread_service_principal.main[each.key].object_id
}
