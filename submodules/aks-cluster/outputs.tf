output "client_key" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
}

output "host" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].host
}

output "username" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].username
}

output "password" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].password
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.main.node_resource_group
}

output "location" {
  value = azurerm_kubernetes_cluster.main.location
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.main.kube_config_raw
}

output "admin_client_key" {
  value = azurerm_kubernetes_cluster.main.kube_admin_config[0].client_key
}

output "admin_client_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_admin_config[0].client_certificate
}

output "admin_cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_admin_config[0].cluster_ca_certificate
}

output "admin_host" {
  value = azurerm_kubernetes_cluster.main.kube_admin_config[0].host
}

output "admin_username" {
  value = azurerm_kubernetes_cluster.main.kube_admin_config[0].username
}

output "admin_password" {
  value = azurerm_kubernetes_cluster.main.kube_admin_config[0].password
}

output "kube_admin_config_raw" {
  value = azurerm_kubernetes_cluster.main.kube_admin_config_raw
}

output "http_application_routing_zone_name" {
  value = length(azurerm_kubernetes_cluster.main.addon_profile) > 0 && length(azurerm_kubernetes_cluster.main.addon_profile[0].http_application_routing) > 0 ? azurerm_kubernetes_cluster.main.addon_profile[0].http_application_routing[0].http_application_routing_zone_name : ""
}

output "system_assigned_identity" {
  value = azurerm_kubernetes_cluster.main.identity
}

output "kubelet_identity" {
  value = azurerm_kubernetes_cluster.main.kubelet_identity
}

output "oms_agent_identity" {
  value = azurerm_kubernetes_cluster.main.kubelet_identity
}

output "configure" {
  value = <<CONFIGURE
Run the following commands to configure kubernetes client:
$ terraform output kube_config_raw > ~/.kube/aksconfig
Remove the first(<<EOT) and the last(EOT) line
$ terraform output kube_config_raw | sed '1d' | sed '$d' > ~/.kube/aksconfig
$ chmod 700 ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig
Test configuration using kubectl
$ kubectl get nodes
CONFIGURE
}
