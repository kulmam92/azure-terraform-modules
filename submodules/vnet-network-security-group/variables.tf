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
  description = "The name of the virtual network. Pass this variable when you want to override the default naming convention."
  default     = ""
  type        = string
}

# https://github.com/hashicorp/terraform/issues/21384
variable "networking_object" {
  description = "(Required) configuration object describing the networking configuration"
}

variable "ddos_id" {
  description = "(Optional) ID of the DDoS protection plan if exists"
  default     = ""
}

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}

