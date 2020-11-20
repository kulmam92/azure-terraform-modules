output "role_assignments" {
  description = "A map of all applied role assignments."
  value = merge(
    azurerm_synapse_role_assignment.user,
    azurerm_synapse_role_assignment.group,
    azurerm_synapse_role_assignment.service_principal
  )
}
