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

##################################
# event hub
##################################
variable "eventhub_namespace_name_override" {
  description = "Name of Event Hub Namespace."
  default     = ""
  type        = string
}

variable "eventhub_sku" {
  description = "Defines which tier to use. Valid options are Basic and Standard."
  default     = "Standard"
}

variable "eventhub_capacity" {
  description = "Specifies the Capacity / Throughput Units for a Standard SKU namespace. Valid values range from 1 - 20."
  type        = number
  default     = 1
}

variable "eventhub_auto_inflate" {
  description = "Is Auto Inflate enabled for the EventHub Namespace, and what is maximum throughput?"
  type        = object({ enabled = bool, maximum_throughput_units = number })
  default     = null
}

variable "eventhub_diagnostics" {
  description = "Diagnostic settings for those resources that support it. See README.md for details on configuration."
  type        = object({ destination = string, eventhub_name = string, logs = list(string), metrics = list(string) })
  default     = null
}

variable "eventhub_authorization_rules" {
  description = "Authorization rules to add to the namespace. For hub use `hubs` variable to add authorization keys."
  type        = list(object({ name = string, listen = bool, send = bool, manage = bool }))
  default     = []
}

variable "eventhub_hubs" {
  description = "A list of event hubs to add to namespace."
  type        = list(object({ name = string, partitions = number, message_retention = number, consumers = list(string), keys = list(object({ name = string, listen = bool, send = bool })) }))
  default     = []
}

variable "eventhub_network_rules" {
  description = "Network rules restricing access to the event hub."
  type        = object({ ip_rules = list(string), subnet_ids = list(string) })
  default     = null
}

variable "eventhub_private_endpoints" {
  description = "map structure for the private endpoint to be created"
  type = map(
    object({
      private_endpoint_name_postfix = string
      private_dns_zone_name         = string
      vnet_resource_group_name      = string
      vnet_name                     = string
      subnet_name                   = string
      # private_service_connection
      subresource_names    = list(string)
      is_manual_connection = string
    }),
  )
}
# value for eventhub
#     private_dns_zone_name = "privatelink.servicebus.database.azure.com"
#     subresource_names = ["namespace"]

variable "eventhub_role_assignments" {
  description = "A list of role assignments (permissions) to apply in the specified scope. Each role assignment object should provide the display name of the target principal, a built-in role that will be given to the target principal,  and the principal type (which can be a user, group, or service_principal)."
  default     = []
  type = list(object({
    name = string
    role = string
    type = string
  }))
}
