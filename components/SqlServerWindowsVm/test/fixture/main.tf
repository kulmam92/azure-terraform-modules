resource "random_id" "randomize" {
  byte_length = 8
}

module "resource_group" {
  source = "../../../../submodules/resource-group"

  name_override      = random_id.randomize.hex
  location           = var.location
  tags               = var.tags
  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}

module "vnet" {
  source = "../../../../submodules/vnet-network-security-group"

  name_override       = random_id.randomize.hex
  resource_group_name = module.resource_group.name
  tags                = var.tags
  networking_object   = var.networking_object
  ddos_id             = var.ddos_id
  account_short_name  = var.account_short_name
  component           = var.component
  environment         = var.environment
  datacenter          = var.datacenter
  product             = var.product
}

module "vm_windows" {
  source = "../../"

  resource_group_name = module.resource_group.name
  tags                = var.tags

  # vm name max length: 15, random_id length: 16
  vm_hostname_override         = substr(random_id.randomize.hex, 1, 12)
  public_ip_dns                = var.public_ip_dns
  nb_public_ip                 = var.nb_public_ip
  remote_port                  = var.remote_port
  nb_instances                 = var.nb_instances
  ssh_public_keys              = var.ssh_public_keys
  admin_password               = var.admin_password
  vm_os_publisher              = var.vm_os_publisher
  vm_os_offer                  = var.vm_os_offer
  vm_os_sku                    = var.vm_os_sku
  vm_size                      = var.vm_size
  vnet_resource_group_name     = module.resource_group.name
  vnet_name                    = module.vnet.vnet_name
  subnet_name                  = module.vnet.vnet_subnet_names[0]
  nsg_name                     = module.vnet.vent_nsg_names[0]
  public_ip_address_allocation = var.public_ip_address_allocation
  boot_diagnostics             = var.boot_diagnostics
  data_disks                   = var.data_disks
  storage_pool                 = var.storage_pool

  account_short_name = var.account_short_name
  component          = var.component
  environment        = var.environment
  datacenter         = var.datacenter
  product            = var.product
}
