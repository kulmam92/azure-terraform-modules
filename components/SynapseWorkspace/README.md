# SynapseWorkspace
Terraform modules to deploy Azure Synapse Workspace.

## Base Code
N/A

## Created Resources
* Storage account
* Synapse workspace
* Synapse role assignment
* Dedicated SQL Pool
* Private endpoint

## Usage
Example showing deployment of a Synapse workspace.
```
component          = "SwTest"
product            = "SwTest"
environment        = "Sandbox"
datacenter         = "WestUS2"
location           = "WestUS2"
account_short_name = "swt"
tags = {
  DataCenter    = "WestUS2"
  Environment   = "Sandbox"
  Terraform     = true
  TerraformPath = "submodule/SynapseWorkspace"
}

sql_admin_username = "synapselduser"
# sql_admin_password = "ComplxP@ssw0rd!"
aad_admin_login = "DBA_sec"
aad_admin_type = "group"

# Rule name needs to be 'AllowAllWindowsAzureIps' if both Start and End Ips are specified as "0.0.0.0\".
firewall_rules = [
  {
    name             = "AllowAllWindowsAzureIps"
    start_ip_address = "0.0.0.0"
    end_ip_address   = "0.0.0.0"
  },
  {
    name             = "myIP"
    start_ip_address = "<My IP Address>"
    end_ip_address   = "<My IP Address>"
  }
]

# Target subnet should set enforce_private_link_endpoint_network_policies = true
private_endpoints = {
  endpoint1 = {
    private_endpoint_name_postfix = "myvm"
    private_dns_zone_name = "privatelink.sql.azuresynapse.net"
    vnet_resource_group_name = "rg-azusw2-XXXXXX"
    vnet_name = "vnet-azusw2-XXXXXX"
    subnet_name = "snet-azusw2-XXXXXX-Shared"
    subresource_names = ["sql"]
    is_manual_connection = "false"
  }
}

# sql pool name can contain only letters, numbers or underscore, The value must be between 1 and 15 characters long
synapse_sql_pool_object = {
  sql_pool1 = {
    name_postfix = "small"
    sku_name     = "DW100c"
    create_mode  = "Default"
  }
}
# Workspace Admin, Apache Spark Admin, Sql Admin
role_assignments = [
  {
    name = "DBA_sec"
    role = "Sql Admin"
    type = "group"
  },
  {
    name = "DBA_sec"
    role = "Workspace Admin"
    type = "group"
  }
]

storage_account_tier             = "Standard"
storage_account_replication_type = "LRS"
storage_account_kind             = "StorageV2"
storage_account_is_hns_enabled   = "true"
```