variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  type        = string
}

variable "synapse_workspace_name" {
  description = "synapse workspace name that the role will be granted"
  type        = string
}

variable "role_assignments" {
  description = "A list of role assignments (permissions) to apply in the specified scope. Each role assignment object should provide the display name of the target principal, a built-in role that will be given to the target principal,  and the principal type (which can be a user, group, or service_principal)."
  default     = []
  type = list(object({
    name = string
    role = string
    type = string
  }))
}
