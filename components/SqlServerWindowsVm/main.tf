module "vm_windows" {
  source = "../../submodules/virtual-machine"

  resource_group_name = var.resource_group_name
  tags                = var.tags

  vm_hostname_override         = var.vm_hostname_override
  public_ip_dns                = var.public_ip_dns
  nb_public_ip                 = var.nb_public_ip
  remote_port                  = var.remote_port
  nb_instances                 = var.nb_instances
  ssh_public_keys              = var.ssh_public_keys
  admin_username               = var.admin_username
  admin_password               = var.admin_password
  vm_os_publisher              = var.vm_os_publisher
  vm_os_offer                  = var.vm_os_offer
  vm_os_sku                    = var.vm_os_sku
  vm_size                      = var.vm_size
  vnet_resource_group_name     = var.vnet_resource_group_name
  vnet_name                    = var.vnet_name
  subnet_name                  = var.subnet_name
  nsg_name                     = var.nsg_name
  public_ip_address_allocation = var.public_ip_address_allocation
  boot_diagnostics             = var.boot_diagnostics
  data_disks                   = var.data_disks

  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}

resource "null_resource" "storage_space" {
  count = var.nb_instances

  triggers = {
    # if value of variable was chnged
    md5 = md5("${jsonencode(var.storage_pool)}")
    # when you want this to run always
    # always_run = "${timestamp()}"
    # if a file was changed
    # md5 = "${filemd5("${path.module}/files/foo.config")}"
  }

  provisioner "local-exec" {
    # ${path.module} means path to the module itself not its caller
    working_dir = "${path.module}/playbooks"
    command     = <<EOT
      ansible-playbook -i ${module.vm_windows.public_ip_dns_name[count.index]}, `
        win_storagespace.yaml --extra-var `
        "ansible_user='${var.admin_username}' `
         ansible_password='${var.admin_password}' `
         storage_pool=${replace(jsonencode(var.storage_pool), "\"", "'")}
        "
    EOT
    interpreter = ["pwsh", "-Command"]
  }
  depends_on = [module.vm_windows]
}

resource "null_resource" "sqlserver" {
  count = var.nb_instances

  triggers = {
    #   # if value of variable was chnged
    #   md5 = md5("${join(",", var.compute_cluster_names)}")
    # when you want this to run always
    always_run = "${timestamp()}"
    #   # if a file was changed
    #   md5 = "${filemd5("${path.module}/files/foo.config")}"
  }

  provisioner "local-exec" {
    # ${path.module} means path to the module itself not its caller
    working_dir = "${path.module}/playbooks"
    command     = <<EOT
      ansible-playbook -i ${module.vm_windows.public_ip_dns_name[count.index]}, `
        win_sql_server.yaml --extra-var `
        "ansible_user='${var.admin_username}' `
         ansible_password='${var.admin_password}'
        "
    EOT
    interpreter = ["pwsh", "-Command"]
  }
  depends_on = [null_resource.storage_space]
}
