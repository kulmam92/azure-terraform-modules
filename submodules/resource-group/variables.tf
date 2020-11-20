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
  description = "The name of the resource group. Pass this variable when you want to override the default naming convention."
  default     = ""
  type        = string
}

variable "tags" {
  description = "Any tags that should be present on the resource group."
  default     = {}
  type        = map(string)
}
