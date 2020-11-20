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

variable "private_connection_resource_id" {
  description = "The ID of the Private Link Enabled Remote Resource which this Private Endpoint should be connected to."
  type        = string
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

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
