# MachineLearningWorkspace
Terraform modules to deploy Azure ML Workspace.

## Base Code
N/A

## Created Resources
* Storage account
* Key vault
* Container registry
* Application insights
* machine learning workspace
* computeInstances - using powershell since Terraform doesn't support this yet.
* computeClusters - using powershell since Terraform doesn't support this yet.

## Usage
Example showing deployment of a ML workspace.
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
  TerraformPath = "components/MachineLearningStudio"
}

# Geo-redundant storage
storage_account_replication_type = "LRS"
storage_account_network_rules = [
  {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = ["/subscriptions/XXXXXX/resourceGroups/rg-azusw2-XXXX/providers/Microsoft.Network/virtualNetworks/vnet-azusw2-XXXXXX/subnets/snet-azusw2-XXXXX-Shared"]
  }
]

key_vault_sku_name = "premium"
key_vault_access_policies = [
  {
    user_principal_names    = ["example@gmail.com"]
    secret_permissions      = ["get", "list"]
  },
  {
    group_names             = ["DBA_sec"]
    secret_permissions      = ["get", "list", "set"]
  },
]
key_vault_network_acls = {
  default_action             = "Deny"
  bypass                     = "AzureServices"
  ip_rules                   = []
  virtual_network_subnet_ids = ["/subscriptions/XXXXXX/resourceGroups/rg-azusw2-XXXX/providers/Microsoft.Network/virtualNetworks/vnet-azusw2-XXXXXX/subnets/snet-azusw2-XXXXX-Shared"]
}

machine_learning_workspace_sku_name = "Enterprise"
# max length: 16, must end with -com
compute_instance_names = ["exmaple-com"]
# max length: 16, must end with -cluster
compute_cluster_names = ["default-cluster"]
# vnet to attach
vnet_resource_group_name = "rg-azusw2-XXXX"
vnet_name = "vnet-azusw2-XXXXXX"
subnet_name = "vnet-azusw2-XXXXXX-Shared"

machine_learning_workspace_role_assignments = [
  {
    name = "DBA_sec"
    role = "Contributor"
    type = "group"
  }
]
```