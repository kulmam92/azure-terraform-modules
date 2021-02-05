variable "account_short_name" {
  description = "The short name of the account."
  type        = string
}

variable "component" {
  description = "The name of the target component."
  type        = string
}

variable "environment" {
  description = "The name of the target environment."
  type        = string
}

variable "datacenter" {
  description = "The name of the target datacenter."
  type        = string
}

variable "product" {
  description = "The name of the target product."
  type        = string
}

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  type        = string
}

variable "name_override" {
  description = "The name of the synapse workspace. Pass this variable when you want to override the default naming convention."
  default     = ""
  type        = string
}

variable "dns_prefix" {
  description = "dns prefix of the Kubernetes cluster."
  default     = null
}

variable "sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid"
  type        = string
  default     = "Free"
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to deploy."
  type        = string
  default     = null
}

variable "private_cluster_enabled" {
  description = "Enabled private cluster."
  type        = bool
  default     = false
}

variable "api_server_authorized_ip_ranges" {
  description = "The IP ranges to whitelist for incoming traffic to the masters."
  type        = list(string)
  default     = null
}

variable "node_resource_group" {
  description = "The name of the Resource Group where the Kubernetes Nodes should exist."
  default     = null
}

variable "linux_profile" {
  description = "Username and ssh key for accessing Linux machines with ssh."
  type        = object({ username = string, ssh_key = string })
  default     = null
}

variable "windows_profile" {
  description = "Admin username and password for Windows hosts."
  type        = object({ username = string, password = string })
  default     = null
}

variable "agent_pools" {
  description = "A list of agent pools to create, each item supports same properties as `agent_pool_profile`. See README for default values."
  type        = list(any)
}
# name                  = each.key
# kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
# vm_size               = each.value.vm_size
# availability_zones    = each.value.availability_zones
# enable_auto_scaling   = each.value.enable_auto_scaling
# node_count            = each.value.count
# min_count             = each.value.min_count
# max_count             = each.value.max_count
# max_pods              = each.value.max_pods
# os_disk_size_gb       = each.value.os_disk_size_gb
# os_type               = each.value.os_type
# vnet_subnet_id        = each.value.vnet_subnet_id
# node_taints           = each.value.node_taints
# tags = var.tags

variable "agent_pool_vnet_resource_group_name" {
  description = "vnet resource group name to add agent pool"
  type        = string
  default     = null
}

variable "agent_pool_vnet_name" {
  description = "vnet name to add agent pool"
  type        = string
  default     = null
}

variable "agent_pool_subnet_name" {
  description = "subnet name to add agent pool"
  type        = string
  default     = null
}

variable "service_principal" {
  description = "Service principal to connect to cluster."
  type        = object({ object_id = string, client_id = string, client_secret = string })
  default     = null
}

variable "addons" {
  description = "Addons to enable / disable."
  type        = object({ http_application_routing = bool, dashboard = bool, oms_agent = bool, oms_agent_workspace_id = string, aci_connector_linux = bool, aci_connector_linux_subnet_name = string, policy = bool })
  default     = { http_application_routing = false, dashboard = false, oms_agent = false, oms_agent_workspace_id = null, aci_connector_linux = false, aci_connector_linux_subnet_name = null, policy = true }
}

variable "network_profile" {
  description = "Network profile for AKS."
  default     = {}
  type        = map(string)
  #object({ network_plugin = string, network_policy = string, dns_service_ip = string, outbound_type = string, docker_bridge_cidr = string, pod_cidr = string, service_cidr = string, load_balancer_sku = string })
}
# network_profile = {
#   network_plugin     = azure or kubenet
#   network_policy     = calico or azure
#   dns_service_ip     = cidrhost(var.service_cidr, 10)
#   outbound_type      = loadBalancer or userDefinedRouting
#   docker_bridge_cidr = var.docker_bridge_cidr # "172.17.0.1/16"
#   pod_cidr           = var.pod_cidr # network_plugin is set to kubenet.
#   service_cidr       = var.service_cidr # If subnet has UDR make sure this is routed correctly.
#   load_balancer_sku  = basic or standard
# }

variable "enable_role_based_access_control" {
  description = "Enable Role Based Access Control."
  type        = bool
  default     = false
}

variable "rbac_aad_managed" {
  description = "Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration."
  type        = bool
  default     = false
}

variable "rbac_aad_admin_group_names" {
  description = "Name of AAD groups with admin access."
  type        = list(string)
  default     = null
}

variable "rbac_azure_active_directory" {
  description = "Azure AD configuration for enabling rbac."
  type        = object({ client_app_id = string, server_app_id = string, server_app_secret = string })
  default     = null
}

variable "admins" {
  description = "List of Azure AD object ids that should be able to impersonate admin user."
  type        = list(object({ kind = string, name = string }))
  default     = []
}

variable "service_accounts" {
  description = "List of service accounts to create and their roles."
  type        = list(object({ name = string, namespace = string, role = string }))
  default     = []
}

variable "diagnostics" {
  description = "Diagnostic settings for those resources that support it. See README.md for details on configuration."
  type        = object({ destination = string, eventhub_name = string, logs = list(string), metrics = list(string) })
  default     = null
}

variable "log_analytics_workspace_sku" {
  description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "The retention period for the logs in days"
  type        = number
  default     = 30
}

variable "enable_log_analytics_workspace" {
  type        = bool
  description = "Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  default     = true
}

# role
variable "container_registries" {
  description = "List of Azure Container Registry ids where AKS needs pull access."
  type        = list(string)
  default     = []
}

variable "storage_contributor" {
  description = "List of storage account ids where the AKS service principal should have access."
  type        = list(string)
  default     = []
}

variable "managed_identities" {
  description = "List of managed identities where the AKS service principal should have access."
  type        = list(string)
  default     = []
}

variable "cert_manager_acme_email" {
  description = "acme email for letsencrypt"
  type        = string
  default     = "kulmam92@gmail.ciom"
}

variable "akv2k8s_key_vault" {
  description = "key vault for akv2k8s"
  type        = string
  default     = ""
}

variable "akv2k8s_key_vault_resource_group" {
  description = "resource group of key vault for akv2k8s"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
