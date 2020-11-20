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

variable "storage_account_replication_type" {
  description = "The type of replication to use for this storage account. LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS"
  default     = "GRS"
  type        = string
}

variable "storage_account_network_rules" {
  description = "default_action - (Required) Specifies the default action of allow or deny when no other rules match. Valid options are Deny or Allow. bypass - (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None. ip_rules - (Optional) List of public IP or IP ranges in CIDR Format. Only IPV4 addresses are allowed. Private IP address ranges (as defined in RFC 1918) are not allowed. virtual_network_subnet_ids - (Optional) A list of resource ids for subnets."
  type = list(object({
    default_action             = string
    bypass                     = list(string)
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  }))
  default = []
}

variable "key_vault_sku_name" {
  description = "The Name of the SKU used for this Key Vault. standard, premium"
  default     = "premium"
  type        = string
}

variable "key_vault_access_policies" {
  type        = any
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "key_vault_secrets" {
  type        = map(string)
  description = "A map of secrets for the Key Vault."
  default     = {}
}

variable "key_vault_network_acls" {
  description = "Object with attributes: `bypass`, `default_action`, `ip_rules`, `virtual_network_subnet_ids`. See https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#bypass for more informations."
  default = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  type = object({
    default_action             = string,
    bypass                     = string,
    ip_rules                   = list(string),
    virtual_network_subnet_ids = list(string),
  })
}

variable "machine_learning_workspace_sku_name" {
  description = "The SKU/edition of the Machine Learning Workspace. Basic, Enterprise"
  default     = "Basic"
  type        = string
}

variable "machine_learning_workspace_role_assignments" {
  description = "A list of role assignments (permissions) to apply in the specified scope. Each role assignment object should provide the display name of the target principal, a built-in role that will be given to the target principal, a scope (the target resource that permissions will be applied to), and the principal type, which can be a user, group, or service_principal."
  default     = []
  type = list(object({
    name = string
    role = string
    type = string
  }))
}

variable "compute_instance_names" {
  description = "A list of computeinstance names. Name must end with -com."
  default     = []
  type        = list(string)
}

variable "compute_cluster_names" {
  description = "A list of computecluster names. Name must end with -cluster."
  default     = []
  type        = list(string)
}

variable "vnet_resource_group_name" {
  description = "vnet resource group name"
  type        = string
}

variable "vnet_name" {
  description = "vnet name to add compute"
  type        = string
}

variable "subnet_name" {
  description = "subnet name to add compute"
  type        = string
}

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
