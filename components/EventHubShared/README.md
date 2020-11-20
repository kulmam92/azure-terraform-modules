# EventHubShared
Terraform modules to deploy Azure Event Hub in Shared Cluster.

## Base Code
[avinor/terraform-azurerm-event-hubs](https://github.com/avinor/terraform-azurerm-event-hubs)

## Created Resources
* Event Hub Namespace
* Event Hub
* Consumer group
* Keys(authorization rules)
* Azure monitor diagnostic setting
* Private endpoint

## Usage
Example showing deployment of a Event Hub Shared.
```
component          = "EhTest"
product            = "EhTest"
environment        = "Sandbox"
datacenter         = "WestUS2"
location           = "WestUS2"
account_short_name = "eht"
tags = {
  DataCenter    = "WestUS2"
  Environment   = "Sandbox"
  Terraform     = true
  TerraformPath = "components/EventHubShared"
}

# eventhub_namespace_name_override = "simple"
eventhub_sku = "Standard"

eventhub_hubs = [
  {
    name = "input"
    partitions = 8
    message_retention = 1
    consumers = [
      "app1",
      "app2"
    ]
    keys = [
      {
        name = "app1"
        listen = true
        send = false
      },
      {
        name = "app2"
        listen = true
        send = true
      }
    ]
  }
]

eventhub_network_rules = {
  ip_rules = []
  subnet_ids = [
    "/subscriptions/XXXXXX/resourceGroups/rg-azusw2-XXXXXX/providers/Microsoft.Network/virtualNetworks/vnet-azusw2-XXXXXX/subnets/snet-azusw2-XXXXXX-Shared",
    "/subscriptions/XXXXXX/resourceGroups/rg-azusw2-XXXXXX/providers/Microsoft.Network/virtualNetworks/vnet-azusw2-XXXXXX/subnets/snet-azusw2-XXXXXX-Database"
  ]
}

eventhub_private_endpoints = {
  endpoint1 = {
    private_endpoint_name_postfix = "myvm"
    private_dns_zone_name = "privatelink.servicebus.database.azure.com"
    vnet_resource_group_name = "rg-azusw2-XXXXXX"
    vnet_name = "vnet-azusw2-XXXXXX"
    subnet_name = "snet-azusw2-XXXXXX-Shared"
    subresource_names = ["namespace"]
    is_manual_connection = "false"
  }
}
```