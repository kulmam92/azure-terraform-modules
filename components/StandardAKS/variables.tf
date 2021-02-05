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

##################################
# Resource Group
##################################
variable "location" {
  description = "The location (Azure region) that the resource group is created in."
  type        = string
}

variable "resource_group_name_override" {
  description = "The name of the resource group. Pass this variable when you want to override the default naming convention."
  default     = ""
  type        = string
}

##################################
# AKS
##################################
variable "aks_name_override" {
  description = "The name of the synapse workspace. Pass this variable when you want to override the default naming convention."
  default     = ""
  type        = string
}

variable "aks_dns_prefix" {
  description = "dns prefix of the Kubernetes cluster."
  default     = null
}

variable "aks_sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid"
  type        = string
  default     = "Free"
}

variable "aks_kubernetes_version" {
  description = "Version of Kubernetes to deploy."
  type        = string
  default     = null
}

variable "aks_private_cluster_enabled" {
  description = "Enabled private cluster."
  type        = bool
  default     = false
}

variable "aks_api_server_authorized_ip_ranges" {
  description = "The IP ranges to whitelist for incoming traffic to the masters."
  type        = list(string)
  default     = null
}

variable "aks_node_resource_group" {
  description = "The name of the Resource Group where the Kubernetes Nodes should exist."
  default     = null
}

variable "aks_linux_profile" {
  description = "Username and ssh key for accessing Linux machines with ssh."
  type        = object({ username = string, ssh_key = string })
  default     = null
}

variable "aks_windows_profile" {
  description = "Admin username and password for Windows hosts."
  type        = object({ username = string, password = string })
  default     = null
}

variable "aks_agent_pools" {
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

variable "aks_agent_pool_vnet_resource_group_name" {
  description = "vnet resource group name to add agent pool"
  type        = string
  default     = null
}

variable "aks_agent_pool_vnet_name" {
  description = "vnet name to add agent pool"
  type        = string
  default     = null
}

variable "aks_agent_pool_subnet_name" {
  description = "subnet name to add agent pool"
  type        = string
  default     = null
}

variable "aks_service_principal" {
  description = "Service principal to connect to cluster."
  type        = object({ object_id = string, client_id = string, client_secret = string })
  default     = null
}

variable "aks_addons" {
  description = "Addons to enable / disable."
  type        = object({ http_application_routing = bool, dashboard = bool, oms_agent = bool, oms_agent_workspace_id = string, aci_connector_linux = bool, aci_connector_linux_subnet_name = string, policy = bool })
  default     = { http_application_routing = false, dashboard = false, oms_agent = false, oms_agent_workspace_id = null, aci_connector_linux = false, aci_connector_linux_subnet_name = null, policy = true }
}

variable "aks_network_profile" {
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

variable "aks_enable_role_based_access_control" {
  description = "Enable Role Based Access Control."
  type        = bool
  default     = false
}

variable "aks_rbac_aad_managed" {
  description = "Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration."
  type        = bool
  default     = false
}

variable "aks_rbac_aad_admin_group_names" {
  description = "Name of AAD groups with admin access."
  type        = list(string)
  default     = null
}

variable "aks_rbac_azure_active_directory" {
  description = "Azure AD configuration for enabling rbac."
  type        = object({ client_app_id = string, server_app_id = string, server_app_secret = string })
  default     = null
}

variable "aks_admins" {
  description = "List of Azure AD object ids that should be able to impersonate admin user."
  type        = list(object({ kind = string, name = string }))
  default     = []
}

variable "aks_service_accounts" {
  description = "List of service accounts to create and their roles."
  type        = list(object({ name = string, namespace = string, role = string }))
  default     = []
}

variable "aks_diagnostics" {
  description = "Diagnostic settings for those resources that support it. See README.md for details on configuration."
  type        = object({ destination = string, eventhub_name = string, logs = list(string), metrics = list(string) })
  default     = null
}

variable "aks_log_analytics_workspace_sku" {
  description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  type        = string
  default     = "PerGB2018"
}

variable "aks_log_retention_in_days" {
  description = "The retention period for the logs in days"
  type        = number
  default     = 30
}

variable "aks_enable_log_analytics_workspace" {
  type        = bool
  description = "Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  default     = true
}

# role
variable "aks_container_registries" {
  description = "List of Azure Container Registry ids where AKS needs pull access."
  type        = list(string)
  default     = []
}

variable "aks_storage_contributor" {
  description = "List of storage account ids where the AKS service principal should have access."
  type        = list(string)
  default     = []
}

variable "aks_managed_identities" {
  description = "List of managed identities where the AKS service principal should have access."
  type        = list(string)
  default     = []
}

variable "aks_cert_manager_acme_email" {
  description = "cert manager acme email"
  type        = string
  default     = ""
}

variable "aks_prometheus_basic_auth" {
  description = "basic auth credential for prometheus in [loginname]:[htpasswd] format. Use 'htpasswd -c auth admin' command to generate password."
  type        = string
  default     = ""
}

##################################
# storage account
##################################
variable "storage_account_name_override" {
  description = "The name of the resource group. Pass this variable when you want to override the default naming convention."
  default     = ""
  type        = string
}
variable "storage_account_kind" {
  description = "Defines the Kind of account. Valid options are Storage, StorageV2 and BlobStorage. Changing this forces a new resource to be created."
  type        = string
  default     = "StorageV2"
}

variable "storage_account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard"
}

variable "storage_account_is_hns_enabled" {
  description = "(Optional) Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2 (see here for more information). Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "storage_account_replication_type" {
  description = "The type of replication to use for this storage account. LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS"
  default     = "LRS"
  type        = string
}

variable "storage_account_network_rules" {
  description = "default_action - (Required) Specifies the default action of allow or deny when no other rules match. Valid options are Deny or Allow. bypass - (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None. ip_rules - (Optional) List of public IP or IP ranges in CIDR Format. Only IPV4 addresses are allowed. Private IP address ranges (as defined in RFC 1918) are not allowed. virtual_network_subnet_ids - (Optional) A list of resource ids for subnets."
  type = list(object({
    default_action             = string
    bypass                     = list(string)
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  }))
  default = []
}

variable "storage_account_shares" {
  type = list(object({
    name  = string
    quota = number
  }))
  default     = []
  description = "List of storage shares."
}

##################################
# key vault
##################################
variable "key_vault_name_override" {
  description = "Name of Key Vault. Naming module will be used if not provided."
  default     = ""
  type        = string
}

variable "key_vault_sku_name" {
  description = "The name of the SKU used for the Key Vault. Possible values include standard and premium."
  default     = "standard"
  type        = string
}

variable "key_vault_enable_rbac_authorization" {
  description = "flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
  type        = bool
  default     = false
}

variable "key_vault_access_policies" {
  type        = any
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "key_vault_secrets" {
  type        = map(string)
  description = "A map of secrets for the Key Vault."
  default     = {}
}

variable "key_vault_network_acls" {
  description = "Object with attributes: `bypass`, `default_action`, `ip_rules`, `virtual_network_subnet_ids`. See https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#bypass for more informations."
  default = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  type = object({
    default_action             = string,
    bypass                     = string,
    ip_rules                   = list(string),
    virtual_network_subnet_ids = list(string),
  })
}

variable "key_vault_role_assignments" {
  description = "A list of role assignments (permissions) to apply in the specified scope. Each role assignment object should provide the display name of the target principal, a built-in role that will be given to the target principal,  and the principal type (which can be a user, group, or service_principal)."
  default     = []
  type = list(object({
    name = string
    role = string
    type = string
  }))
}

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
