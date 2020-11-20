# Network Security Group definition
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

variable "name_override" {
  description = "The name of the network secutiry group. Pass this variable when you want to override the default naming convention."
  default     = ""
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# https://github.com/hashicorp/terraform/issues/21384
variable "subnets" {
  description = "map structure for the subnets to be created"
}
# type = object({
#   vnet = object({
#     name_overwrite  = string
#     address_space   = list(string)
#     dns             = list(string)
#     enable_ddos_std = bool
#     ddos_id         = string
#   }),
#   subnets = map(
#     object({
#       name_postfix                                   = string
#       cidr                                           = list(string)
#       service_endpoints                              = list(string)
#       enforce_private_link_endpoint_network_policies = string
#       enforce_private_link_service_network_policies  = string
#       nsg_name_postfix                               = string
#       nsg                                            = list(map(string))
#       delegation                                     = object({
#         name = string
#         service_delegation = object({
#           name = string
#           actions = list(string)
#         }),
#       })
#     }),
#   ),
# })

variable "tags" {
  description = "The tags to associate with your network security group."
  type        = map(string)
  default     = {}
}
