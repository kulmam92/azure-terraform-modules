# Configure cluster
# provider "kubernetes" {
#   load_config_file       = "false"
#   host                   = azurerm_kubernetes_cluster.main.kube_admin_config.0.host
#   username               = azurerm_kubernetes_cluster.main.kube_admin_config.0.username
#   password               = azurerm_kubernetes_cluster.main.kube_admin_config.0.password
#   client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_admin_config.0.client_certificate)
#   client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_admin_config.0.client_key)
#   cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_admin_config.0.cluster_ca_certificate)
# }

#
# Impersonation of admins
#

# terraform output kube_config_raw | sed '1d' | sed '$d' > ~/.kube/aksconfig
# resource "local_file" "aksconfig" {
#   content  = azurerm_kubernetes_cluster.main.kube_config_raw
#   filename = "./aksconfig"
# }

resource "kubernetes_cluster_role" "impersonator" {
  metadata {
    name = "impersonator"
  }

  rule {
    api_groups = [""]
    resources  = ["users", "groups", "serviceaccounts"]
    verbs      = ["impersonate"]
  }
}

resource "kubernetes_cluster_role_binding" "impersonator" {
  count = length(var.admins)

  metadata {
    name = "${var.admins[count.index].name}-administrator"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.impersonator.metadata.0.name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = var.admins[count.index].kind
    name      = var.admins[count.index].name
  }
}

#
# Container logs for Azure
#

resource "kubernetes_cluster_role" "containerlogs" {
  metadata {
    name = "containerhealth-log-reader"
  }

  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "containerlogs" {
  metadata {
    name = "containerhealth-read-logs-global"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.containerlogs.metadata.0.name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "clusterUser"
  }
}

#
# Service accounts
#

resource "kubernetes_service_account" "sa" {
  count = length(var.service_accounts)

  metadata {
    name      = var.service_accounts[count.index].name
    namespace = var.service_accounts[count.index].namespace
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "sa" {
  count = length(var.service_accounts)

  metadata {
    name = var.service_accounts[count.index].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.service_accounts[count.index].role
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.service_accounts[count.index].name
    namespace = var.service_accounts[count.index].namespace
  }
}

data "kubernetes_secret" "sa" {
  count = length(var.service_accounts)

  metadata {
    name      = kubernetes_service_account.sa[count.index].default_secret_name
    namespace = var.service_accounts[count.index].namespace
  }
}
