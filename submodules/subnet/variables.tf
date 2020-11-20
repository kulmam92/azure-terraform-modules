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
  description = "Default resource group name that the network will be created in."
  type        = string
}

variable "virtual_network_name" {
  description = "name of the parent virtual network"
  type        = string
}

# https://github.com/hashicorp/terraform/issues/21384
variable "subnets" {
  description = "map structure for the subnets to be created"
}

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
