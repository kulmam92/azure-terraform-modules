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

  display_name = each.value.name
}

data "azuread_service_principal" "main" {
  for_each = local.service_principal_role_assignments

  display_name = each.value.name
}

resource "azurerm_role_assignment" "user" {
  for_each = local.user_role_assignments

  principal_id         = data.azuread_user.main[each.key].id
  role_definition_name = each.value.role
  scope                = var.scope
}

resource "azurerm_role_assignment" "group" {
  for_each = local.group_role_assignments

  principal_id         = data.azuread_group.main[each.key].id
  role_definition_name = each.value.role
  scope                = var.scope
}

resource "azurerm_role_assignment" "service_principal" {
  for_each = local.service_principal_role_assignments

  principal_id         = data.azuread_service_principal.main[each.key].object_id
  role_definition_name = each.value.role
  scope                = var.scope

  skip_service_principal_aad_check = true
}
