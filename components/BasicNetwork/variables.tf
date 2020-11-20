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
  description = "The location (Azure region) that the resources are created in."
  type        = string
}

# https://community.gruntwork.io/t/variables-with-compound-structure-any-workaround/100/3
# Note that because the values are being passed in with environment variables and json,
# the type information is lost when crossing the boundary between Terragrunt and Terraform.
# You must specify the proper type constraint on the variable in Terraform in order for Terraform to process the inputs to the right type.
variable "networking_object" {
  description = "(Required) configuration object describing the networking configuration"
  type = object({
    vnet = object({
      name_overwrite  = string
      address_space   = list(string)
      dns             = list(string)
      enable_ddos_std = bool
      ddos_id         = string
    }),
    subnets = map(
      object({
        name_postfix                                   = string
        cidr                                           = list(string)
        service_endpoints                              = list(string)
        enforce_private_link_endpoint_network_policies = string
        enforce_private_link_service_network_policies  = string
        nsg_name_postfix                               = string
        nsg                                            = list(map(string))
        delegation = object({
          name = string
          service_delegation = object({
            name    = string
            actions = list(string)
          }),
        })
      }),
    ),
  })
}

# networking_object = {
#   vnet = {
#     name            = "_Shared_Services"
#     address_space   = ["10.101.4.0/22"]
#     dns             = ["1.2.3.4"]
#     enable_ddos_std = false
#     ddos_id         = "/subscriptions/783438ca-d497-4350-aa36-dc55fb0983ab/resourceGroups/testrg/providers/Microsoft.Network/ddosProtectionPlans/test"
#   }
#   subnets = {
#     subnet0 = {
#       name     = "Cycle_Controller"
#       cidr     = ["10.101.4.0/25"]
#       nsg_name = "Cycle_Controller_nsg"
#     }
#     subnet1 = {
#       name     = "Active_Directory"
#       cidr     = ["10.101.4.128/27"]
#       nsg_name = "Active_Directory_nsg"
#       nsg = [
#         {
#           name                       = "W32Time",
#           priority                   = "100"
#           direction                  = "Inbound"
#           access                     = "Allow"
#           protocol                   = "UDP"
#           source_port_range          = "*"
#           destination_port_range     = "123"
#           source_address_prefix      = "*"
#           destination_address_prefix = "*"
#         },
#         {
#           name                       = "RPC-Endpoint-Mapper",
#           priority                   = "101"
#           direction                  = "Inbound"
#           access                     = "Allow"
#           protocol                   = "UDP"
#           source_port_range          = "*"
#           destination_port_range     = "135"
#           source_address_prefix      = "*"
#           destination_address_prefix = "*"
#         },
#         {
#           name                       = "Kerberos-password-change",
#           priority                   = "102"
#           direction                  = "Inbound"
#           access                     = "Allow"
#           protocol                   = "*"
#           source_port_range          = "*"
#           destination_port_range     = "464"
#           source_address_prefix      = "*"
#           destination_address_prefix = "*"
#         },
#         {
#           name                       = "RPC-Dynamic-range",
#           priority                   = "103"
#           direction                  = "Inbound"
#           access                     = "Allow"
#           protocol                   = "tcp"
#           source_port_range          = "*"
#           destination_port_range     = "49152-65535"
#           source_address_prefix      = "*"
#           destination_address_prefix = "*"
#         },
#         {
#           name                       = "RPC-Dynamic-range",
#           priority                   = "103"
#           direction                  = "Inbound"
#           access                     = "Allow"
#           protocol                   = "tcp"
#           source_port_range          = "*"
#           destination_port_range     = "49152-65535"
#           source_address_prefix      = "*"
#           destination_address_prefix = "*"
#         }
#       ]
#     }
#     subnet2 = {
#       name = "SQL_Servers"
#       cidr = ["10.101.4.160/27"]
#       # service_endpoints   = []
#       nsg_name = "SQL_Servers_nsg"
#       nsg = [
#         {
#           name                       = "TDS",
#           priority                   = "100"
#           direction                  = "Inbound"
#           access                     = "Allow"
#           protocol                   = "*"
#           source_port_range          = "*"
#           destination_port_range     = "1433"
#           source_address_prefix      = "*"
#           destination_address_prefix = "*"
#         }
#       ]
#     }
#     subnet3 = {
#       name              = "Network_Monitoring"
#       cidr              = ["10.101.4.192/27"]
#       service_endpoints = ["Microsoft.Sql"]
#       nsg_name          = "Network_Monitoring_nsg"
#     }
#   }
# }

variable "ddos_id" {
  description = "(Optional) ID of the DDoS protection plan if exists"
  default     = ""
}

variable "route_table_name" {
  description = "The name of the RouteTable being created."
  default     = "routetable"
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
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
