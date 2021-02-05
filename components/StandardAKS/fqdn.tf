data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [helm_release.ingress_nginx]
}

# keep returning empty list while it's visualble on portal
# data "azurerm_public_ips" "aks" {
#   resource_group_name = module.aks.node_resource_group
#   attached            = true

#   depends_on = [module.aks, helm_release.ingress_nginx]
# }

module "aks_public_ips" {
  source  = "matti/resource/shell"
  trigger = timestamp()
  environment = {
    NODE_RESOURCE_GROUP = module.aks.node_resource_group
  }

  # Retry 24 times with delay to obtain public ip
  # az network public-ip list --resource-group $NODE_RESOURCE_GROUP --query "[?contains(name, 'kubernetes')].{id:id}" --output tsv
  command = <<EOT
    ./${path.module}/resources/set-fqdn.sh $NODE_RESOURCE_GROUP
  EOT

  depends_on = [module.aks, helm_release.ingress_nginx]
}

resource "null_resource" "echo_public_ip" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      echo ${module.aks_public_ips.stdout}
    EOT
  }

  depends_on = [module.aks_public_ips]
}

module "aks_dns_name" {
  source = "matti/resource/shell"

  # trigger = md5(join(",", [var.aks_dns_prefix]))
  trigger = timestamp()
  environment = {
    PUBLIC_IP_ID   = module.aks_public_ips.stdout
    ASK_DNS_PREFIX = var.aks_dns_prefix
  }

  command = <<EOT
    az network public-ip update \
      --ids $PUBLIC_IP_ID \
      --dns-name $ASK_DNS_PREFIX
  EOT

  depends_on = [module.aks_public_ips, data.kubernetes_service.ingress_nginx]
}

module "aks_dns_name_get" {
  source = "matti/resource/shell"

  environment = {
    PUBLIC_IP_ID = module.aks_public_ips.stdout
  }

  command = <<EOT
    az network public-ip show --ids $PUBLIC_IP_ID --query [dnsSettings.fqdn] --output tsv
  EOT

  depends_on = [module.aks_dns_name]
}
