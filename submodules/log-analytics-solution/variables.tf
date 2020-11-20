variable "resource_group_name" {
  description = "The name of the resource group to contain the created resources."
  type        = string
}

variable "solution" {
  description = "An object containing the solution and plan information. This includes the name of the solution to be deployed, the publisher of the solution (e.g. Microsoft), and the product name of the solution (e.g. OMSGallery/Containers). Changing any one of these properties will force a new resource to be created."
  type = object({
    name      = string
    publisher = string
    product   = string
  })
}

variable "workspace_resource_id" {
  description = "The full resource ID of the Log Analytics workspace with which the solution will be linked. Changing this forces a new resource to be created."
  type        = string
}

variable "workspace_name" {
  description = "The full name of the Log Analytics workspace with which the solution will be linked. Changing this forces a new resource to be created."
  type        = string
}
