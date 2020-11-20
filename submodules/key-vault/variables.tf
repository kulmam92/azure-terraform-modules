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

variable "sku_name" {
  description = "The name of the SKU used for the Key Vault. Possible values include standard and premium."
  default     = "standard"
  type        = string
}

variable "network_acls" {
  description = "Object with attributes: `bypass`, `default_action`, `ip_rules`, `virtual_network_subnet_ids`. See https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#bypass for more informations."
  default     = {
    default_action = "Deny"
    bypass         = "AzureServices"
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

variable "access_policies" {
  type        = any
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "secrets" {
  type        = map(string)
  description = "A map of secrets for the Key Vault."
  default     = {}
}

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}

locals {
  access_policies = [
    for p in var.access_policies : merge({
      group_names             = []
      object_ids              = []
      user_principal_names    = []
      certificate_permissions = []
      key_permissions         = []
      secret_permissions      = []
      storage_permissions     = []
    }, p)
  ]

  group_names          = distinct(flatten(local.access_policies[*].group_names))
  user_principal_names = distinct(flatten(local.access_policies[*].user_principal_names))

  group_object_ids = { for g in data.azuread_group.main : lower(g.name) => g.id }
  user_object_ids  = { for u in data.azuread_user.main : lower(u.user_principal_name) => u.id }

  flattened_access_policies = concat(
    flatten([
      for p in local.access_policies : flatten([
        for i in p.object_ids : {
          object_id               = i
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.group_names : {
          object_id               = local.group_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.user_principal_names : {
          object_id               = local.user_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ])
  )

  grouped_access_policies = { for p in local.flattened_access_policies : p.object_id => p... }

  combined_access_policies = [
    for k, v in local.grouped_access_policies : {
      object_id               = k
      certificate_permissions = distinct(flatten(v[*].certificate_permissions))
      key_permissions         = distinct(flatten(v[*].key_permissions))
      secret_permissions      = distinct(flatten(v[*].secret_permissions))
      storage_permissions     = distinct(flatten(v[*].storage_permissions))
    }
  ]

  service_principal_object_id = data.azurerm_client_config.main.object_id

  self_permissions = {
    object_id               = local.service_principal_object_id
    tenant_id               = data.azurerm_client_config.main.tenant_id
    key_permissions         = ["create", "delete", "get"]
    secret_permissions      = ["delete", "get", "set"]
    certificate_permissions = []
    storage_permissions     = []
  }
}