# # provider "kustomization" {
# #   kubeconfig_raw = azurerm_kubernetes_cluster.main.kube_admin_config_raw
# # }

# # ArgoCD
# data "kustomization" "argocd" {
#   path = "${path.module}/manifests/argocd/argocd-bootstrap/"

#   depends_on = [helm_release.cert_manager, helm_release.ingress_nginx, azurerm_role_assignment.akv2k8s_secret_user]
# }

# # https://github.com/kbst/terraform-provider-kustomization/issues/18
# data "template_file" "argocd" {
#   for_each = data.kustomization.argocd.ids
#   #   template = data.kustomization.argocd.manifests[each.value]
#   template = replace(data.kustomization.argocd.manifests[each.value], "/\\$\\{([^_KUSVAR])/", "$$$${$1")

#   vars = {
#     _KUSVAR_FQDN       = module.aks_dns_name_get.stdout
#     _KUSVAR_ACME_EMAIL = var.cert_manager_acme_email
#   }

#   depends_on = [azurerm_kubernetes_cluster.main, data.kustomization.argocd]
# }

# resource "kustomization_resource" "argocd" {
#   for_each = data.kustomization.argocd.ids

#   manifest = data.template_file.argocd[each.value].rendered

#   depends_on = [azurerm_kubernetes_cluster.main, data.template_file.argocd]
# }
