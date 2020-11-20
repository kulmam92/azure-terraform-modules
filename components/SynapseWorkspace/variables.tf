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

variable "location" {
  description = "The location (Azure region) that the resource group is created in."
  type        = string
}

variable "name_override" {
  description = "The name of the synapse workspace. Pass this variable when you want to override the default naming convention."
  default     = ""
  type        = string
}

variable "sql_admin_username" {
  description = "The admin username of the sql"
  default     = "azurelduser"
}

variable "sql_admin_password" {
  description = "The admin password of sql_admin_username. The password must meet the complexity requirements of Azure"
  default     = ""
}

variable "aad_admin_login" {
  description = "The Azure AD admin name of the sql"
  type = string
  default     = ""
}

variable "aad_admin_type" {
  description = "The object type of Azure AD admin of the sql - user, group, service_principal"
  type = string
  default     = ""
}

variable "firewall_rules" {
  description = "list of firewall rules."
  type        = list(map(string))
  default     = []
}

variable "private_endpoints" {
  description = "map structure for the private endpoint to be created"
}
# type = map(
#   object({
#     private_endpoint_name_postfix = string
#     private_dns_zone_name = "privatelink.sql.azuresynapse.net"
#     vnet_resource_group_name = string
#     vnet_name = string
#     subnet_name = string
#     # private_service_connection
#     subresource_names = ["sql"]
#     is_manual_connection = string
#   }),
# )

variable "synapse_sql_pool_object" {
  description = "map structure for the synaps sql pools to be created"
}

variable "role_assignments" {
  description = "A list of role assignments (permissions) to apply in the specified scope. Each role assignment object should provide the display name of the target principal, a built-in role that will be given to the target principal,  and the principal type (which can be a user, group, or service_principal)."
  default     = []
  type = list(object({
    name = string
    role = string
    type = string
  }))
}

variable "networking_object" {
  description = "(Required) configuration object describing the networking configuration"
}

variable "ddos_id" {
  description = "(Optional) ID of the DDoS protection plan if exists"
  default     = ""
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

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
