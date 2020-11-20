# Base code: https://github.com/avinor/terraform-azurerm-event-hubs
module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}

data "azurerm_resource_group" "events" {
  name       = var.resource_group_name
  depends_on = [var.resource_group_name]
}

locals {
  consumers = { for hc in flatten([for h in var.hubs :
    [for c in h.consumers : {
      hub  = h.name
      name = c
  }]]) : format("%s.%s", hc.hub, hc.name) => hc }
  # Use Terraform console to check the value
  # $ terraform console
  # > { for hc in flatten([for h in var.hubs : [for c in h.consumers : { hub  = h.name, name = c }]]) : format("%s.%s", hc.hub, hc.name) => hc }
  # sample result
  #  {
  #   "input.app1" = {
  #     "hub" = "input"
  #     "name" = "app1"
  #   }
  #   "input.app2" = {
  #     "hub" = "input"
  #     "name" = "app2"
  #   }
  # }

  keys = { for hk in flatten([for h in var.hubs :
    [for k in h.keys : {
      hub = h.name
      key = k
  }]]) : format("%s.%s", hk.hub, hk.key.name) => hk }

  hubs                = { for h in var.hubs : h.name => h }
  authorization_rules = { for a in var.authorization_rules : a.name => a }

  diag_namespace_logs = [
    "ArchiveLogs",
    "AutoScaleLogs",
    "CustomerManagedKeyUserLogs",
    "EventHubVNetConnectionEvent",
    "KafkaCoordinatorLogs",
    "KafkaUserErrorLogs",
    "OperationalLogs",
  ]
  diag_namespace_metrics = [
    "AllMetrics",
  ]

  diag_resource_list = var.diagnostics != null ? split("/", var.diagnostics.destination) : []
  parsed_diag = var.diagnostics != null ? {
    log_analytics_id   = contains(local.diag_resource_list, "microsoft.operationalinsights") ? var.diagnostics.destination : null
    storage_account_id = contains(local.diag_resource_list, "Microsoft.Storage") ? var.diagnostics.destination : null
    event_hub_auth_id  = contains(local.diag_resource_list, "Microsoft.EventHub") ? var.diagnostics.destination : null
    metric             = contains(var.diagnostics.metrics, "all") ? local.diag_namespace_metrics : var.diagnostics.metrics
    log                = contains(var.diagnostics.logs, "all") ? local.diag_namespace_logs : var.diagnostics.logs
    } : {
    log_analytics_id   = null
    storage_account_id = null
    event_hub_auth_id  = null
    metric             = []
    log                = []
  }
}

resource "azurerm_eventhub_namespace" "events" {
  name                = var.eventhub_namespace_name_override != "" ? var.eventhub_namespace_name_override : module.naming.eventhub_namespace.name
  location            = data.azurerm_resource_group.events.location
  resource_group_name = data.azurerm_resource_group.events.name
  sku                 = var.sku
  capacity            = var.capacity

  auto_inflate_enabled     = var.auto_inflate != null ? var.auto_inflate.enabled : null
  maximum_throughput_units = var.auto_inflate != null ? var.auto_inflate.maximum_throughput_units : null

  dynamic "network_rulesets" {
    for_each = var.network_rules != null ? ["true"] : []
    content {
      default_action = "Deny"

      dynamic "ip_rule" {
        for_each = var.network_rules.ip_rules
        iterator = iprule
        content {
          ip_mask = iprule.value
        }
      }

      dynamic "virtual_network_rule" {
        for_each = var.network_rules.subnet_ids
        iterator = subnet
        content {
          subnet_id = subnet.value
        }
      }
    }
  }

  tags = var.tags
}

resource "azurerm_eventhub_namespace_authorization_rule" "events" {
  for_each = local.authorization_rules

  name                = join("-", [module.naming.eventhub_namespace_authorization_rule.name, each.key])
  namespace_name      = azurerm_eventhub_namespace.events.name
  resource_group_name = data.azurerm_resource_group.events.name

  listen = each.value.listen
  send   = each.value.send
  manage = each.value.manage
}

resource "azurerm_eventhub" "events" {
  for_each = local.hubs

  name                = join("-", [module.naming.eventhub.name, each.key])
  namespace_name      = azurerm_eventhub_namespace.events.name
  resource_group_name = data.azurerm_resource_group.events.name
  partition_count     = each.value.partitions
  message_retention   = each.value.message_retention
}

resource "azurerm_eventhub_consumer_group" "events" {
  for_each = local.consumers

  name                = join("-", [module.naming.eventhub_consumer_group.name, each.key])
  namespace_name      = azurerm_eventhub_namespace.events.name
  eventhub_name       = join("-", [module.naming.eventhub.name, each.value.hub])
  resource_group_name = data.azurerm_resource_group.events.name
  user_metadata       = "terraform"

  depends_on = [azurerm_eventhub.events]
}

resource "azurerm_eventhub_authorization_rule" "events" {
  for_each = local.keys

  name                = each.key # join("-", [module.naming.eventhub_authorization_rule.name,each.key])
  namespace_name      = azurerm_eventhub_namespace.events.name
  eventhub_name       = join("-", [module.naming.eventhub.name, each.value.hub])
  resource_group_name = data.azurerm_resource_group.events.name

  listen = each.value.key.listen
  send   = each.value.key.send
  manage = false

  depends_on = [azurerm_eventhub.events]
}

resource "azurerm_monitor_diagnostic_setting" "namespace" {
  count = var.diagnostics != null ? 1 : 0
  # Azure/naming/azurerm doesn't support azurerm_monitor_diagnostic_setting
  name                           = var.eventhub_namespace_name_override != "" ? "diag-ns-${var.eventhub_namespace_name_override}" : "diag-${module.naming.eventhub_namespace.name}"
  target_resource_id             = azurerm_eventhub_namespace.events.id
  log_analytics_workspace_id     = local.parsed_diag.log_analytics_id
  eventhub_authorization_rule_id = local.parsed_diag.event_hub_auth_id
  eventhub_name                  = local.parsed_diag.event_hub_auth_id != null ? var.diagnostics.eventhub_name : null
  storage_account_id             = local.parsed_diag.storage_account_id

  dynamic "log" {
    for_each = local.parsed_diag.log
    content {
      category = log.value

      retention_policy {
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = local.parsed_diag.metric
    content {
      category = metric.value

      retention_policy {
        enabled = false
      }
    }
  }
}

# create private endpoint
module "private_endpoint" {
  source = "../../submodules/private-endpoint"

  resource_group_name = data.azurerm_resource_group.events.name
  tags                = var.tags

  private_connection_resource_id = azurerm_eventhub_namespace.events.id
  private_endpoints              = var.private_endpoints

  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}
