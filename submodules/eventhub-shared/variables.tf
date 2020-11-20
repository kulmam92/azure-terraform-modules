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

variable "eventhub_namespace_name_override" {
  description = "Name of Event Hub Namespace."
  default     = ""
  type        = string
}

variable "sku" {
  description = "Defines which tier to use. Valid options are Basic and Standard."
  default     = "Standard"
}

variable "capacity" {
  description = "Specifies the Capacity / Throughput Units for a Standard SKU namespace. Valid values range from 1 - 20."
  type        = number
  default     = 1
}

variable "auto_inflate" {
  description = "Is Auto Inflate enabled for the EventHub Namespace, and what is maximum throughput?"
  type        = object({ enabled = bool, maximum_throughput_units = number })
  default     = null
}

variable "diagnostics" {
  description = "Diagnostic settings for those resources that support it. See README.md for details on configuration."
  type        = object({ destination = string, eventhub_name = string, logs = list(string), metrics = list(string) })
  default     = null
}

variable "network_rules" {
  description = "Network rules restricing access to the event hub."
  type        = object({ ip_rules = list(string), subnet_ids = list(string) })
  default     = null
}

variable "private_endpoints" {
  description = "map structure for the private endpoint to be created"
}
# type = map(
#   object({
#     private_endpoint_name_postfix = string
#     private_dns_zone_name = string
#     vnet_resource_group_name = string
#     vnet_name = string
#     subnet_name = string
#     # private_service_connection
#     subresource_names = list(string)
#     is_manual_connection = string
#   }),
# )

variable "authorization_rules" {
  description = "Authorization rules to add to the namespace. For hub use `hubs` variable to add authorization keys."
  type        = list(object({ name = string, listen = bool, send = bool, manage = bool }))
  default     = []
}

variable "hubs" {
  description = "A list of event hubs to add to namespace."
  type        = list(object({ name = string, partitions = number, message_retention = number, consumers = list(string), keys = list(object({ name = string, listen = bool, send = bool })) }))
  default     = []
}

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
