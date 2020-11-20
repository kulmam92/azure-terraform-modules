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

variable "storage_account_resource_group_name" {
  description = "storage account resource group name"
  type        = string
}

variable "storage_account_name" {
  description = "storage account name to add compute"
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

# Rule name needs to be 'AllowAllWindowsAzureIps' if both Start and End Ips are specified as "0.0.0.0\".
# 'AllowAllWindowsAzureIps' will turn 'Allow Azure services and resources to access this workspace' option on
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

# sql pool name can contain only letters, numbers or underscore, The value must be between 1 and 15 characters long
variable "synapse_sql_pool_object" {
  description = "map structure for the synaps sql pools to be created"
  default     = {}
  type        = map(map(string))
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

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
