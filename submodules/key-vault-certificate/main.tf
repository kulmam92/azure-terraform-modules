resource "azurerm_key_vault_certificate" "main" {
  name         = var.certificate_name
  key_vault_id = var.key_vault_id

  certificate {
    contents = filebase64(var.certificate_file_path)
    password = var.certificate_password
  }

  certificate_policy {
    issuer_parameters {
      name = var.issuer_parameter_name
    }

    key_properties {
      exportable = var.exportable
      key_size   = var.key_size
      key_type   = var.key_type
      reuse_key  = var.reuse_key
    }

    secret_properties {
      content_type = var.content_type
    }
  }

  tags = var.tags
}
