output "id" {
  description = "The ID of the Key Vault certificate."
  value       = azurerm_key_vault_certificate.main.id
}

output "secret_id" {
  description = "The ID of the associated Key Vault secret."
  value       = azurerm_key_vault_certificate.main.secret_id
}

output "version" {
  description = "The current version of the Key Vault certificate."
  value       = azurerm_key_vault_certificate.main.version
}

output "certificate_data" {
  description = "The raw Key Vault certificate data represented as a hexadecimal string."
  value       = azurerm_key_vault_certificate.main.certificate_data
}

output "thumbprint" {
  description = "The X509 thumbprint of the Key Vault certificate represented as a hexadecimal string."
  value       = azurerm_key_vault_certificate.main.thumbprint
}

output "certificate_attribute" {
  description = "A certificate_attribute block, describing the creation time, expiration time, recovery level etc."
  value       = azurerm_key_vault_certificate.main.certificate_attribute
}
