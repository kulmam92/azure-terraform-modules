# # install foundational helm charts
# # Need to decide whether we will use ARGO CD or Terraform
# provider "helm" {
#   kubernetes {
#     host                   = azurerm_kubernetes_cluster.main.kube_admin_config.0.host
#     username               = azurerm_kubernetes_cluster.main.kube_admin_config.0.username
#     password               = azurerm_kubernetes_cluster.main.kube_admin_config.0.password
#     client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_admin_config.0.client_certificate)
#     client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_admin_config.0.client_key)
#     cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_admin_config.0.cluster_ca_certificate)
#   }
# }

# # https://www.hashicorp.com/blog/deploy-any-resource-with-the-new-kubernetes-provider-for-hashicorp-terraform
# provider "kubernetes-alpha" {
#   host                   = module.aks.aks_admin_host
#   username               = module.aks.aks_admin_username
#   password               = module.aks.aks_admin_password
#   client_certificate     = base64decode(module.aks.aks_admin_client_certificate)
#   client_key             = base64decode(module.aks.aks_admin_client_key)
#   cluster_ca_certificate = base64decode(module.aks.aks_admin_cluster_ca_certificate)
# }


##########################################
# namespace
##########################################
resource "kubernetes_namespace" "akv2k8s" {
  metadata {
    name = "akv2k8s"
  }

  depends_on = [module.aks]
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }

  depends_on = [module.aks]
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }

  depends_on = [module.aks]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    annotations = {
      name                          = "argocd"
      azure-key-vault-env-injection = "enabled"
    }
  }

  depends_on = [module.aks]
}

# ##########################################
# # akv2k8s
# ##########################################
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "akv2k8s" {
  name       = "akv2k8s"
  repository = "http://charts.spvapi.no"
  chart      = "akv2k8s"
  namespace  = "akv2k8s"
  #   version    = ""

  depends_on = [kubernetes_namespace.akv2k8s]
}

# grant KV access permission for akv2k8s
data "azurerm_key_vault" "akv2k8s" {
  name                = module.key_vault.key_vault_name
  resource_group_name = module.resource_group.name

  depends_on = [data.azurerm_key_vault.akv2k8s, module.aks]
}

module "aks_agentpool_principal_id" {
  source  = "matti/resource/shell"
  trigger = md5(join(",", [module.aks.kubelet_identity[0].user_assigned_identity_id]))

  command = <<EOT
    az identity show --ids '${module.aks.kubelet_identity[0].user_assigned_identity_id}' --query "principalId" --output tsv
  EOT

  depends_on = [module.aks]
}

resource "azurerm_role_assignment" "akv2k8s_reader" {
  scope                = data.azurerm_key_vault.akv2k8s.id
  role_definition_name = "Key Vault Reader"
  principal_id         = module.aks_agentpool_principal_id.stdout

  depends_on = [module.aks_agentpool_principal_id, module.aks]
}

resource "azurerm_role_assignment" "akv2k8s_secret_user" {
  scope                = data.azurerm_key_vault.akv2k8s.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.aks_agentpool_principal_id.stdout

  depends_on = [module.aks_agentpool_principal_id, module.aks]
}

##########################################
# ingress_nginx
##########################################
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  #   version    = ""

  #   values = [
  #     "${file("values.yaml")}"
  #   ]

  #   set: Value block with custom values to be merged with the values yaml
  set {
    name  = "controller.replicaCount"
    value = "2"
  }
  set {
    name  = "controller.nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }
  set {
    name  = "defaultBackend.nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }

  depends_on = [kubernetes_namespace.ingress_nginx]
}

##########################################
# cert_manager
##########################################
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "1.1.0"
  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }
  depends_on = [kubernetes_namespace.cert_manager, module.aks]
}

##########################################
# ArgoCd
##########################################
# resource "helm_release" "argocd" {
#   name       = "argo-cd"
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"
#   namespace  = "argocd"
#   version    = "2.11.0"
#   values = [
#     file("${path.module}/manifests/argocd/values.yaml")
#   ]
#   depends_on = [helm_release.cert_manager, module.aks]
# }

resource "null_resource" "argocd" {
  triggers = {
    # md5 = filemd5("${path.module}/manifests/argocd/base/bootstrap-cluster.yaml")
    always_run = timestamp()
  }
  # https://medium.com/citihub/a-more-secure-way-to-call-kubectl-from-terraform-1052adf37af8
  provisioner "local-exec" {
    environment = {
      KUBECONFIG     = base64encode(module.aks.kube_admin_config_raw)
    }
    command     = <<EOT
      kustomize build ${path.module}/manifests/argocd/argocd-bootstrap | \
      kubectl -n argocd --kubeconfig <(echo $KUBECONFIG | base64 --decode) apply -f -
      sleep 60
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  # provisioner "local-exec" {
  #   when    = destroy
  #   environment = {
  #     KUBECONFIG     = base64encode(module.aks.kube_admin_config_raw)
  #   }
  #   command = "kubectl delete namespace argocd --kubeconfig <(echo $KUBECONFIG | base64 --decode)"
  #   working_dir = path.module
  # }

  depends_on = [helm_release.ingress_nginx, module.aks]
}

resource "null_resource" "argocd_app" {
  triggers = {
    # md5 = filemd5("${path.module}/manifests/argocd/base/bootstrap-cluster.yaml")
    always_run = timestamp()
  }
  # https://medium.com/citihub/a-more-secure-way-to-call-kubectl-from-terraform-1052adf37af8
  provisioner "local-exec" {
    environment = {
      KUBECONFIG     = base64encode(module.aks.kube_admin_config_raw)
      VAR_FQDN       = module.aks_dns_name_get.stdout
      VAR_ACME_EMAIL = var.aks_cert_manager_acme_email
    }
    command     = <<EOT
      echo $VAR_FQDN
      echo $VAR_ACME_EMAIL
      cat ${path.module}/manifests/argocd/app/bootstrap-cluster.yaml | \
      sed "s/{_KUSVAR_FQDN}/$VAR_FQDN/g" | \
      sed "s/{_KUSVAR_ACME_EMAIL}/$VAR_ACME_EMAIL/g" | \
      kubectl -n argocd --kubeconfig <(echo $KUBECONFIG | base64 --decode) apply -f -
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [null_resource.argocd, module.aks_dns_name_get, module.aks]
}

# keep getting error when provider configuration is not provided as a file
# resource "kubernetes_manifest" "argocd-app" {
#   provider = kubernetes-alpha
#   manifest = {
#     apiVersion = "argoproj.io/v1alpha1"
#     kind       = "Application"
#     metadata = {
#       name = "bootstrap-cluster"
#       finalizers = [
#         "resources-finalizer.argocd.argoproj.io"
#       ]
#     }
#     spec = {
#       destination = {
#         namespace = "argocd"
#         server    = "https://kubernetes.default.svc"
#       }
#       project = "default"
#       source = {
#         repoURL        = "https://github.com/kulmam92/argocd-test.git"
#         targetRevision = "HEAD"
#         path           = "applications/bootstrap-cluster"
#         helm = {
#           parameters = [
#             {
#               name  = "hosts"
#               value = module.aks_dns_name_get.stdout
#             },
#             {
#               name  = "acme_email"
#               value = var.cert_manager_acme_email
#             }
#           ]
#           valueFiles = [
#             "values.yaml"
#           ]
#         }
#       }
#       syncPolicy = {
#         automated = {
#           prune = true
#         }
#         validate = true
#       }
#     }
#   }
# }
