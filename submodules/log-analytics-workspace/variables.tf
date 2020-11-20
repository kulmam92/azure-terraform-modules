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
  description = "The name of the resource group to contain the created resources."
  type        = string
}

variable "sku" {
  description = "The SKU (pricing level) of the Log Analytics workspace. Possible values include Free, PerNode, Premium, Standard, Standalone, Unlimited, and PerGB2018."
  default     = "PerGB2018"
  type        = string
}

variable "retention_in_days" {
  description = "The workspace data retention in days. Possible values are either 7 (free tier only) or range between 30 and 730."
  default     = 30
  type        = number
}

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
