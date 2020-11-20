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
  description = "The name of the RouteTable being created. Pass this variable when you want to override the default naming convention."
  default     = ""
  type        = string
}

variable "disable_bgp_route_propagation" {
  description = "Boolean flag which controls propagation of routes learned by BGP on that route table. True means disable."
  default     = "true"
}

variable "route_prefixes" {
  description = "The list of address prefixes to use for each route."
  type        = list(string)
  default     = []
}

variable "route_names" {
  description = "A list of public subnets inside the vNet."
  type        = list(string)
  default     = []
}

variable "route_nexthop_types" {
  description = "The type of Azure hop the packet should be sent to for each corresponding route.Valid values are 'VirtualNetworkGateway', 'VnetLocal', 'Internet', 'HyperNetGateway', 'None'"
  type        = list(string)
  default     = null
}

variable "route_next_hop_in_ip_address" {
  description = "Contains the IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance."
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  default     = {}
  type        = map(string)
}
