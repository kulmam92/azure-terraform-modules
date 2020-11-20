output "role_assignments" {
  description = "A map of all applied role assignments."
  value = merge(
    azurerm_role_assignment.user,
    azurerm_role_assignment.group,
    azurerm_role_assignment.service_principal
  )
}
