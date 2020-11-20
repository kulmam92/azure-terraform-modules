variable "certificate_name" {
  description = "The name of the Key Vault certificate. Changing this forces a new resource to be created."
  type        = string
}

variable "certificate_file_path" {
  description = "The file path to the certificate. This will most likely be a certificate in \\\\s-devopsfiles\\DevOps\\Certificates\\Azure."
  type        = string
}

variable "certificate_password" {
  description = "The password associated with the certificate. Changing this forces a new resource to be created."
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Key Vault where the certificate should be stored."
  type        = string
}

variable "issuer_parameter_name" {
  description = "The name of the certificate issuer. Possible values include Self (for self-signed certificate), or Unknown (for a certificate issuing authority like Let's Encrypt and Azure direct supported ones). Changing this forces a new resource to be created."
  default     = "Unknown"
  type        = string
}

variable "exportable" {
  description = "Specifies if the certificate is exportable. Changing this forces a new resource to be created."
  default     = true
  type        = bool
}

variable "key_size" {
  description = "The size of the key used in the certificate. Possible values include 2048 and 4096. Changing this forces a new resource to be created."
  default     = 2048
  type        = number
}

variable "key_type" {
  description = "Specifies the type of key, such as RSA. Changing this forces a new resource to be created."
  default     = "RSA"
  type        = string
}

variable "reuse_key" {
  description = "Specifies if the key is reusable. Changing this forces a new resource to be created."
  default     = false
  type        = bool
}

variable "content_type" {
  description = "The content-type of the certificate, such as application/x-pkcs12 for a PFX or application/x-pem-file for a PEM. Changing this forces a new resource to be created."
  default     = "application/x-pkcs12"
  type        = string
}

variable "tags" {
  description = "Any tags that should be present on the created resources."
  default     = {}
  type        = map(string)
}
