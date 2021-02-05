module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}

data "azurerm_subscription" "current" {
}

data "azurerm_resource_group" "main" {
  name       = var.resource_group_name
  depends_on = [var.resource_group_name]
}

data "azurerm_subnet" "main" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}
# data.azurerm_subnet.main.id

resource "azurerm_application_insights" "main" {
  # application insights is not supported by naming module yet.
  name                = join("-", ["ai", lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)])
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  application_type    = "web"
}

module "storage_account" {
  source              = "../../submodules/storage-account"
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = var.tags
  # The account_tier cannot be Premium in order to associate the Storage Account to this Machine Learning Workspace.
  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication_type
  network_rules            = var.storage_account_network_rules
  account_short_name       = var.account_short_name
  component                = var.component
  environment              = var.environment
  datacenter               = var.datacenter
  product                  = var.product
}

module "key_vault" {
  source = "../../submodules/key-vault"

  resource_group_name = data.azurerm_resource_group.main.name
  tags                = var.tags
  sku_name            = var.key_vault_sku_name
  access_policies     = var.key_vault_access_policies
  secrets             = var.key_vault_secrets
  network_acls        = var.key_vault_network_acls
  role_assignments    = var.key_vault_role_assignments

  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}

resource "azurerm_container_registry" "main" {
  name                = module.naming.container_registry.name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = "Premium" # Your Azure Container Registry must be Premium version
  admin_enabled       = true

  network_rule_set {
    default_action = "Deny"
    virtual_network = [
      {
        action    = "Allow"
        subnet_id = data.azurerm_subnet.main.id
      },
    ]
  }
}

resource "azurerm_machine_learning_workspace" "main" {
  name                    = module.naming.machine_learning_workspace.name
  location                = data.azurerm_resource_group.main.location
  resource_group_name     = data.azurerm_resource_group.main.name
  tags                    = var.tags
  application_insights_id = azurerm_application_insights.main.id
  key_vault_id            = module.key_vault.id
  storage_account_id      = module.storage_account.storage_account_id
  # https://docs.microsoft.com/en-us/azure/machine-learning/how-to-manage-quotas#private-endpoint-and-private-dns-quota-increases
  container_registry_id = azurerm_container_registry.main.id
  sku_name              = var.machine_learning_workspace_sku_name

  identity {
    type = "SystemAssigned"
  }
}

resource "null_resource" "computeinstance" {
  triggers = {
    # if value of variable was chnged
    md5 = md5("${join(",", var.compute_instance_names)}")
    # when you want this to run always
    # always_run = "${timestamp()}"
    # if a file was changed
    # md5 = "${filemd5("${path.module}/files/foo.config")}"
  }
  # create computeInstances after workspace creation.
  provisioner "local-exec" {
    # ${path.module} means path to the module itself not its caller
    working_dir = "${path.module}/script/"
    command     = <<EOT
      ./deploy-computeobject.ps1 `
          -subscriptionName ${data.azurerm_subscription.current.display_name} `
          -resourceGroupName ${data.azurerm_resource_group.main.name} `
          -workspaceName ${azurerm_machine_learning_workspace.main.name} `
          -computeObjectNames ${join(",", var.compute_instance_names)} `
          -computeObjectType instance `
          -vnetResourceGroupName ${var.vnet_resource_group_name} `
          -vnetName ${var.vnet_name} `
          -subnetName ${var.subnet_name}
   EOT
    interpreter = ["pwsh", "-Command"]
  }

  depends_on = [azurerm_machine_learning_workspace.main]
}

resource "null_resource" "computecluster" {
  triggers = {
    # if value of variable was chnged
    md5 = md5("${join(",", var.compute_cluster_names)}")
    # when you want this to run always
    # always_run = "${timestamp()}"
    # if a file was changed
    # md5 = "${filemd5("${path.module}/files/foo.config")}"
  }
  # create computeClusters after workspace creation.
  provisioner "local-exec" {
    # ${path.module} means path to the module itself not its caller
    working_dir = "${path.module}/script/"
    command     = <<EOT
      ./deploy-computeobject.ps1 `
          -subscriptionName ${data.azurerm_subscription.current.display_name} `
          -resourceGroupName ${data.azurerm_resource_group.main.name} `
          -workspaceName ${azurerm_machine_learning_workspace.main.name} `
          -computeObjectNames ${join(",", var.compute_cluster_names)} `
          -computeObjectType cluster `
          -vnetResourceGroupName ${var.vnet_resource_group_name} `
          -vnetName ${var.vnet_name} `
          -subnetName ${var.subnet_name}
   EOT
    interpreter = ["pwsh", "-Command"]
  }

  depends_on = [azurerm_machine_learning_workspace.main]
}
