provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.aks.aks_admin_host
  username               = module.aks.aks_admin_username
  password               = module.aks.aks_admin_password
  client_certificate     = base64decode(module.aks.aks_admin_client_certificate)
  client_key             = base64decode(module.aks.aks_admin_client_key)
  cluster_ca_certificate = base64decode(module.aks.aks_admin_cluster_ca_certificate)
}

# https://www.hashicorp.com/blog/deploy-any-resource-with-the-new-kubernetes-provider-for-hashicorp-terraform
# Until the below issue is fixed
# https://github.com/hashicorp/terraform-provider-kubernetes-alpha/issues/133
# provider "kubernetes-alpha" {
#   server_side_planning = true
#   # config_path            = "${path.module}/aksconfig"
#   host                   = module.aks.aks_admin_host
#   username               = module.aks.aks_admin_username
#   password               = module.aks.aks_admin_password
#   client_certificate     = base64decode(module.aks.aks_admin_client_certificate)
#   client_key             = base64decode(module.aks.aks_admin_client_key)
#   cluster_ca_certificate = base64decode(module.aks.aks_admin_cluster_ca_certificate)
# }

provider "helm" {
  kubernetes {
    host                   = module.aks.aks_admin_host
    username               = module.aks.aks_admin_username
    password               = module.aks.aks_admin_password
    client_certificate     = base64decode(module.aks.aks_admin_client_certificate)
    client_key             = base64decode(module.aks.aks_admin_client_key)
    cluster_ca_certificate = base64decode(module.aks.aks_admin_cluster_ca_certificate)
  }
}

# provider "kustomization" {
#   kubeconfig_raw = module.aks.kube_admin_config_raw
# }
