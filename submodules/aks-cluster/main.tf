# https://github.com/Azure/terraform-azurerm-aks
# https://github.com/avinor/terraform-azurerm-kubernetes
# https://github.com/patuzov/terraform-private-aks
locals {
  default_agent_profile = {
    node_count          = 1
    vm_size             = "Standard_D2_v3"
    os_type             = "Linux"
    availability_zones  = null
    enable_auto_scaling = false
    min_count           = null
    max_count           = null
    type                = "VirtualMachineScaleSets"
    node_taints         = null
  }

  # Defaults for Linux profile
  # Generally smaller images so can run more pods and require smaller HD
  default_linux_node_profile = {
    max_pods        = 30
    os_disk_size_gb = 60
  }

  # Defaults for Windows profile
  # Do not want to run same number of pods and some images can be quite large
  default_windows_node_profile = {
    max_pods        = 20
    os_disk_size_gb = 200
  }

  agent_pools_with_defaults = [for ap in var.agent_pools :
    # add missing elements using default values
    merge(local.default_agent_profile, ap)
  ]
  agent_pools = { for ap in local.agent_pools_with_defaults :
    ap.name => ap.os_type == "Linux" ? merge(local.default_linux_node_profile, ap) : merge(local.default_windows_node_profile, ap)
  }
  default_pool = var.agent_pools[0].name

  # Determine which load balancer to use
  agent_pool_availability_zones_lb = [for ap in local.agent_pools : ap.availability_zones != null ? "Standard" : ""]
  load_balancer_sku                = coalesce(flatten([local.agent_pool_availability_zones_lb, ["Standard"]])...)

  # Distinct subnets
  # agent_pool_subnets = distinct([for ap in local.agent_pools : ap.vnet_subnet_id])

  # Diagnostic settings
  diag_kube_logs = [
    "kube-apiserver",
    "kube-audit",
    "kube-audit-admin",
    "kube-controller-manager",
    "kube-scheduler",
    "cluster-autoscaler",
    "guard",
  ]
  diag_kube_metrics = [
    "AllMetrics",
  ]

  diag_resource_list = var.diagnostics != null ? split("/", var.diagnostics.destination) : []
  parsed_diag = var.diagnostics != null ? {
    log_analytics_id   = contains(local.diag_resource_list, "microsoft.operationalinsights") ? var.diagnostics.destination : null
    storage_account_id = contains(local.diag_resource_list, "Microsoft.Storage") ? var.diagnostics.destination : null
    event_hub_auth_id  = contains(local.diag_resource_list, "Microsoft.EventHub") ? var.diagnostics.destination : null
    metric             = contains(var.diagnostics.metrics, "all") ? local.diag_kube_metrics : var.diagnostics.metrics
    log                = contains(var.diagnostics.logs, "all") ? local.diag_kube_logs : var.diagnostics.metrics
    } : {
    log_analytics_id   = null
    storage_account_id = null
    event_hub_auth_id  = null
    metric             = []
    log                = []
  }
}

module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}


data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azuread_group" "aks_cluster_admins" {
  count = length(var.rbac_aad_admin_group_names)

  display_name = var.rbac_aad_admin_group_names[count.index]
}

data "azurerm_subnet" "main" {
  name                 = var.agent_pool_subnet_name
  virtual_network_name = var.agent_pool_vnet_name
  resource_group_name  = var.agent_pool_vnet_resource_group_name
}
# data.azurerm_subnet.main.id

data "azurerm_kubernetes_service_versions" "current" {
  location = data.azurerm_resource_group.main.location
}

module "ssh-key" {
  source         = "../../submodules/ssh-key"
  public_ssh_key = var.linux_profile.ssh_key == "" ? "" : var.linux_profile.ssh_key
}

resource "azurerm_kubernetes_cluster" "main" {
  name                    = var.name_override != "" ? var.name_override : module.naming.kubernetes_cluster.name
  location                = data.azurerm_resource_group.main.location
  resource_group_name     = data.azurerm_resource_group.main.name
  private_cluster_enabled = var.private_cluster_enabled
  dns_prefix              = var.dns_prefix
  sku_tier                = var.sku_tier
  # Enable automatic upgrades
  kubernetes_version              = var.kubernetes_version == null ? data.azurerm_kubernetes_service_versions.current.latest_version : var.kubernetes_version
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  node_resource_group             = var.node_resource_group == null ? join("-", [data.azurerm_resource_group.main.name, "aks"]) : var.node_resource_group

  dynamic "linux_profile" {
    for_each = var.linux_profile != null ? [true] : []
    iterator = lp
    content {
      admin_username = var.linux_profile.username

      ssh_key {
        # key_data = var.linux_profile.ssh_key
        # remove any new lines using the replace interpolation function
        key_data = replace(var.linux_profile.ssh_key == "" ? module.ssh-key.public_ssh_key : var.linux_profile.ssh_key, "\n", "")
      }
    }
  }

  dynamic "windows_profile" {
    for_each = var.windows_profile != null ? [true] : []
    iterator = wp
    content {
      admin_username = var.windows_profile.username
      admin_password = var.windows_profile.password
    }
  }

  dynamic "default_node_pool" {
    for_each = { for k, v in local.agent_pools : k => v if k == local.default_pool }
    iterator = ap
    content {
      name = ap.value.name
      # you will get below error without this logic
      # Error: expanding `default_node_pool`: cannot change `node_count` when `enable_auto_scaling` is set to `true`
      node_count = ap.value.enable_auto_scaling ? null : ap.value.node_count
      # Enable automatic upgrades
      orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
      vm_size              = ap.value.vm_size
      availability_zones   = ap.value.availability_zones
      enable_auto_scaling  = ap.value.enable_auto_scaling
      min_count            = ap.value.min_count
      max_count            = ap.value.max_count
      max_pods             = ap.value.max_pods
      os_disk_size_gb      = ap.value.os_disk_size_gb
      type                 = ap.value.type
      # Route Table must be configured on this Subnet.
      # must be set for the default_node_pool when network_plugin = azure
      vnet_subnet_id = data.azurerm_subnet.main.id
      node_taints    = ap.value.node_taints
      tags           = var.tags
    }
  }

  # The cluster infrastructure authentication specified is used by Azure Kubernetes Service to manage cloud resources attached to the cluster.
  dynamic "service_principal" {
    for_each = var.service_principal != null ? ["service_principal"] : []
    content {
      client_id     = var.service_principal.client_id
      client_secret = var.service_principal.client_secret
    }
  }

  dynamic "identity" {
    for_each = var.service_principal == null ? ["identity"] : []
    content {
      type = "SystemAssigned"
    }
  }

  addon_profile {
    http_application_routing {
      enabled = var.addons.http_application_routing
    }

    dynamic "oms_agent" {
      for_each = var.addons.oms_agent ? ["log_analytics"] : []
      content {
        enabled                    = true
        log_analytics_workspace_id = var.addons.oms_agent_workspace_id == null ? azurerm_log_analytics_workspace.main[0].id : var.addons.oms_agent_workspace_id
      }
    }

    dynamic "aci_connector_linux" {
      for_each = var.addons.aci_connector_linux && var.addons.aci_connector_linux_subnet_name != null ? ["aci_connector"] : []
      content {
        enabled     = true
        subnet_name = var.addons.aci_connector_linux_subnet_name
      }
    }

    # Kubernetes Dashboard addon is deprecated for Kubernetes version >= 1.19.0.
    # kube_dashboard {
    #   enabled = var.addons.dashboard
    # }

    azure_policy {
      enabled = var.addons.policy
    }
  }

  role_based_access_control {
    enabled = var.enable_role_based_access_control

    dynamic "azure_active_directory" {
      for_each = var.enable_role_based_access_control && var.rbac_aad_managed ? ["rbac"] : []
      content {
        managed                = true
        admin_group_object_ids = flatten(data.azuread_group.aks_cluster_admins.*.object_id)
      }
    }

    dynamic "azure_active_directory" {
      for_each = var.enable_role_based_access_control && !var.rbac_aad_managed ? ["rbac"] : []
      content {
        managed           = false
        client_app_id     = var.rbac_azure_active_directory.client_app_id
        server_app_id     = var.rbac_azure_active_directory.server_app_id
        server_app_secret = var.rbac_azure_active_directory.server_app_secret
      }
    }
  }

  dynamic "network_profile" {
    for_each = var.network_profile != {} ? ["profile"] : []
    content {
      network_plugin     = var.network_profile.network_plugin
      network_policy     = var.network_profile.network_policy
      dns_service_ip     = var.network_profile.dns_service_ip == null && var.network_profile.service_cidr != null ? cidrhost(var.network_profile.service_cidr, 10) : var.network_profile.dns_service_ip
      outbound_type      = var.network_profile.outbound_type == null ? "loadBalancer" : var.network_profile.outbound_type
      docker_bridge_cidr = var.network_profile.docker_bridge_cidr
      pod_cidr           = var.network_profile.network_plugin == "azure" ? null : var.network_profile.pod_cidr
      service_cidr       = var.network_profile.service_cidr
      load_balancer_sku  = local.load_balancer_sku
    }
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each = { for k, v in local.agent_pools : k => v if k != local.default_pool }

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  # Enable automatic upgrades
  orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
  vm_size              = each.value.vm_size
  availability_zones   = each.value.availability_zones
  enable_auto_scaling  = each.value.enable_auto_scaling
  node_count           = each.value.node_count
  min_count            = each.value.min_count
  max_count            = each.value.max_count
  max_pods             = each.value.max_pods
  os_disk_size_gb      = each.value.os_disk_size_gb
  os_type              = each.value.os_type
  vnet_subnet_id       = data.azurerm_subnet.main.id
  node_taints          = each.value.node_taints

  tags = var.tags
}

# azure monitor diagnostics
resource "azurerm_monitor_diagnostic_setting" "main" {
  count                          = var.diagnostics != null ? 1 : 0
  name                           = join("-", ["diag", module.naming.kubernetes_cluster.name])
  target_resource_id             = azurerm_kubernetes_cluster.main.id
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

# log analytics
resource "azurerm_log_analytics_workspace" "main" {
  count               = var.addons.oms_agent && var.addons.oms_agent_workspace_id == null ? 1 : 0
  name                = module.naming.log_analytics_workspace.name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_retention_in_days

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "main" {
  count                 = var.addons.oms_agent && var.addons.oms_agent_workspace_id == null ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main[0].id
  workspace_name        = azurerm_log_analytics_workspace.main[0].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = var.tags
}

# Assign roles
resource "azurerm_role_assignment" "acr" {
  count                = length(var.container_registries)
  scope                = var.container_registries[count.index]
  role_definition_name = "AcrPull"
  principal_id         = var.service_principal.object_id
}

# resource "azurerm_role_assignment" "subnet" {
#   count                = var.agent_pool_subnet_name != null ? 1 : 0
#   scope                = data.azurerm_subnet.main.id
#   role_definition_name = "Network Contributor"
#   principal_id         = var.service_principal.object_id
# }

resource "azurerm_role_assignment" "storage" {
  count                = length(var.storage_contributor)
  scope                = var.storage_contributor[count.index]
  role_definition_name = "Storage Account Contributor"
  principal_id         = var.service_principal.object_id
}

resource "azurerm_role_assignment" "msi" {
  count                = length(var.managed_identities)
  scope                = var.managed_identities[count.index]
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.service_principal.object_id
}
