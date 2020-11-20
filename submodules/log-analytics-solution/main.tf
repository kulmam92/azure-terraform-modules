data "azurerm_resource_group" "main" {
  name = var.resource_group_name
  depends_on = [var.resource_group_name]
}

resource "azurerm_log_analytics_solution" "main" {
  solution_name       = var.solution.name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  workspace_resource_id = var.workspace_resource_id
  workspace_name        = var.workspace_name

  plan {
    publisher = var.solution.publisher
    product   = var.solution.product
  }
}
