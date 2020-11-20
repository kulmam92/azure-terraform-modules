# BasicNetwork
Terraform modules to deploy Basic Network resources.

## Base Code
N/A

## Created Resources
* Vnet
* Subnet
* NSG
* Route table

## Usage
Example showing deployment of a Basic Network.
```
component          = "DataNetwork"
product            = "DataNetwork"
environment        = "Sandbox"
datacenter         = "WestUS2"
location           = "WestUS2"
account_short_name = "dnt"
tags = {
  DataCenter    = "WestUS2"
  Environment   = "Sandbox"
  Terraform     = true
  TerraformPath = "components/BasicNetwork"
}

route_prefixes               = ["0.0.0.0/0"]
route_nexthop_types          = ["Internet"]
route_next_hop_in_ip_address = [null]
route_names                  = ["Inertnet"]

networking_object = {
  vnet = {
    name_overwrite  = null
    address_space   = ["10.20.228.0/22"]
    dns             = []
    enable_ddos_std = false
    ddos_id         = null
  }
  subnets = {
    subnet1 = {
      name_postfix                                   = "Shared"
      cidr                                           = ["10.20.228.128/25"]
      service_endpoints                              = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry","Microsoft.Sql","Microsoft.EventHub"]
      enforce_private_link_endpoint_network_policies = true
      enforce_private_link_service_network_policies  = null
      nsg_name_postfix                               = "Shared"
      nsg = [
        # Required rules for ML workspace
        # https://github.com/terraform-providers/terraform-provider-azurerm/issues/1629
        # https://docs.microsoft.com/en-us/Azure/machine-learning/how-to-secure-training-vnet#mlcports
        {
          name                       = "AzureBatch",
          priority                   = "1040"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "TCP"
          source_port_range          = "*"
          destination_port_range     = "29876-29877"
          source_address_prefix      = "BatchNodeManagement"
          destination_address_prefix = "*"
        },
        {
          name                       = "AzureMachineLearning",
          priority                   = "1050"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "TCP"
          source_port_range          = "*"
          destination_port_range     = "44224"
          source_address_prefix      = "AzureMachineLearning" #Source service tag
          destination_address_prefix = "*"                    # * means Any
        },
        # Ansible
        # RDP
        {
          name                       = "Allow-RDP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3389"
          source_address_prefix      = "<My IP Address>"
          destination_address_prefix = "*"
        },
        # WinRM
        {
          name                       = "Allow-WinRM"
          priority                   = 101
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "5985-5986"
          source_address_prefix      = "<My IP Address>"
          destination_address_prefix = "*"
        }
      ]
      delegation = null
    }
    subnet2 = {
      name_postfix                                   = "Database"
      cidr                                           = ["10.20.228.0/26"]
      # https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview
      service_endpoints                              = ["Microsoft.Storage", "Microsoft.KeyVault","Microsoft.Sql","Microsoft.EventHub"]
      enforce_private_link_endpoint_network_policies = null
      enforce_private_link_service_network_policies  = null
      nsg_name_postfix                               = "Database"
      nsg = [
        # Ansible
        # RDP
        {
          name                       = "Allow-RDP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3389"
          source_address_prefix      = "<My IP Address>"
          destination_address_prefix = "*"
        },
        # WinRM
        {
          name                       = "Allow-WinRM"
          priority                   = 101
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "5985-5986"
          source_address_prefix      = "<My IP Address>"
          destination_address_prefix = "*"
        }
      ]
      delegation = null
    }
  }
}
```