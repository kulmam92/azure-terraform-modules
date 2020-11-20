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
  description = "The name of the resource group to contain the created resources."
  type        = string
}

variable "name_override" {
  description = "The name of the resource group. Pass this variable when you want to override the default naming convention."
  default     = ""
  type        = string
}

variable "account_kind" {
  description = "Defines the Kind of account. Valid options are Storage, StorageV2 and BlobStorage. Changing this forces a new resource to be created."
  type        = string
  default     = "StorageV2"
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS and ZRS."
  type        = string
  default     = "LRS"
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage accounts. Valid options are Hot and Cold, defaults to Hot."
  type        = string
  default     = "Hot"
}

variable "https_traffic" {
  description = "Boolean flag which forces HTTPS if enabled"
  type        = string
  default     = true
}

variable "containers" {
  type = list(object({
    name        = string
    access_type = string
  }))
  default     = []
  description = "List of storage containers."
}

variable "shares" {
  type = list(object({
    name  = string
    quota = number
  }))
  default     = []
  description = "List of storage shares."
}

variable "network_rules" {
  description = "default_action - (Required) Specifies the default action of allow or deny when no other rules match. Valid options are Deny or Allow. bypass - (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices, or None. ip_rules - (Optional) List of public IP or IP ranges in CIDR Format. Only IPV4 addresses are allowed. Private IP address ranges (as defined in RFC 1918) are not allowed. virtual_network_subnet_ids - (Optional) A list of resource ids for subnets."
  type = list(object({
    default_action                 = string
    bypass                         = list(string)
    ip_rules                       = list(string)
    virtual_network_subnet_ids     = list(string)
  }))
  default = []
}

variable "blob_properties_cors_rules" {
  description = "allowed_headers - (Required) A list of headers that are allowed to be a part of the cross-origin request. allowed_methods - (Required) A list of http headers that are allowed to be executed by the origin. Valid options are DELETE, GET, HEAD, MERGE, POST, OPTIONS, PUT or PATCH. allowed_origins - (Required) A list of origin domains that will be allowed by CORS. exposed_headers - (Required) A list of response headers that are exposed to CORS clients. max_age_in_seconds - (Required) The number of seconds the client should cache a preflight response.."
  type = list(object({
    allowed_headers         = list(string)
    allowed_methods         = list(string)
    allowed_origins         = list(string)
    exposed_headers         = list(string)
    max_age_in_seconds      = number
  }))
  default = []
}

variable "is_hns_enabled" {
  description = "(Optional) Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2 (see here for more information). Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "lifcecycle_rules" {
description = "rule supports the following: name - (Required) A rule name can contain any combination of alpha numeric characters. Rule name is case-sensitive. It must be unique within a policy. enabled - (Required) Boolean to specify whether the rule is enabled. prefix_match -  prefix of container names, an array of strings for prefixes to be matched. blob_types - An array of predefined values. Only blockBlob is supported. tier_to_cool_after_days_since_modification_greater_than - The age in days after last modification to tier blobs to cool storage. Supports blob currently at Hot tier. Must be at least 0. tier_to_archive_after_days_since_modification_greater_than - The age in days after last modification to tier blobs to archive storage. Supports blob currently at Hot or Cool tier. Must be at least 0. delete_after_days_since_modification_greater_than - The age in days after last modification to delete the blob. Must be at least 0. delete_after_days_since_creation_greater_than - The age in days after create to delete the snaphot. Must be at least 0."
  type = list(object({
    name                    = string
    enabled                 = bool
    prefix_match            = list(string)
    blob_types              = list(string)
    tier_to_cool_after_days_since_modification_greater_than     = number
    tier_to_archive_after_days_since_modification_greater_than  = number
    delete_after_days_since_modification_greater_than           = number
    delete_snapshot_after_days_since_creation_greater_than  = number
  }))
  default = []
}

variable "add_lifecycle_rules" {
  description = "to add lifcecycle rules"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
