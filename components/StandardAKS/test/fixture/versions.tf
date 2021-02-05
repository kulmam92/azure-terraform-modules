terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.19.0 and above) requires Terraform 0.12.0 or above.
  required_version = ">= 0.13"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
    # kubernetes-alpha = {
    #   source  = "hashicorp/kubernetes-alpha"
    #   version = ">= 0.2.1"
    # }
    # kustomization = {
    #   source  = "kbst/kustomization"
    #   version = ">= 0.3"
    # }
  }
}
