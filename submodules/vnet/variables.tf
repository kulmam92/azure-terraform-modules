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

variable "address_space" {
  description = "The address space that is used by the virtual network."
  type        = string
}

# If no values specified, this defaults to Azure DNS
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  type        = list(string)
  default     = []
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  type        = list(string)
}

variable "subnet_service_endpoints" {
  description = "A list of Service endpoints to associate with the subnet."
  type        = list(string)
}

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
