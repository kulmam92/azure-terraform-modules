# Base code: https://github.com/Azure/terraform-azurerm-vm
locals {
  vm_data_disks = flatten([
    for i in range(var.nb_instances) : [
      for disk in var.data_disks : {
        vm_index             = i
        create_option        = disk.create_option
        lun                  = disk.lun
        disk_size_gb         = disk.disk_size_gb
        storage_account_type = disk.storage_account_type
        caching              = disk.caching
      }
    ]
  ])
}

module "naming" {
  # source = "Azure/naming/azurerm"
  source = "../../submodules/local-terraform-azurerm-naming"
  suffix = [lower(var.datacenter), lower(var.account_short_name), lower(var.environment), lower(var.component)]
}

module "os" {
  source       = "./os"
  vm_os_simple = var.vm_os_simple
}

# resource "random_password" "password" {
#   length           = 16
#   special          = true
#   override_special = "_%@"
# }

data "azurerm_resource_group" "vm" {
  name       = var.resource_group_name
  depends_on = [var.resource_group_name]
}

data "azurerm_subnet" "vm" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
  depends_on           = [var.vnet_resource_group_name]
}

data "azurerm_network_security_group" "vm" {
  name                = var.nsg_name
  resource_group_name = var.vnet_resource_group_name
  depends_on          = [var.vnet_resource_group_name]
}

# data "azurerm_key_vault" "vm" {
#   name                = var.key_vault_name
#   resource_group_name = var.key_vault_resource_group_name
# }

resource "azurerm_storage_account" "vm-sa" {
  count                    = var.boot_diagnostics == "true" ? 1 : 0
  name                     = var.vm_hostname_override != "" ? join("", [var.vm_hostname_override, "st"]) : module.naming.storage_account.name_unique
  resource_group_name      = data.azurerm_resource_group.vm.name
  location                 = data.azurerm_resource_group.vm.location
  account_tier             = element(split("_", var.boot_diagnostics_sa_type), 0)
  account_replication_type = element(split("_", var.boot_diagnostics_sa_type), 1)
  tags                     = var.tags
}

resource "azurerm_linux_virtual_machine" "vm-linux" {
  count                           = ! contains(list(var.vm_os_simple, var.vm_os_offer), "WindowsServer") && var.is_windows_image != "true" ? var.nb_instances : 0
  name                            = var.vm_hostname_override != "" ? join("", [var.vm_hostname_override, count.index]) : join("", [module.naming.virtual_machine.name, count.index])
  resource_group_name             = data.azurerm_resource_group.vm.name
  location                        = data.azurerm_resource_group.vm.location
  availability_set_id             = var.availability_set == "true" ? azurerm_availability_set.vm[0].id : null
  size                            = var.vm_size
  network_interface_ids           = [element(azurerm_network_interface.vm.*.id, count.index)]
  computer_name                   = var.vm_hostname_override != "" ? join("", [var.vm_hostname_override, count.index]) : join("", [module.naming.virtual_machine.name, count.index])
  admin_username                  = var.admin_username
  admin_password                  = length(var.ssh_public_keys) == 0 ? var.admin_password : ""
  disable_password_authentication = length(var.ssh_public_keys) != 0
  dynamic "admin_ssh_key" {
    for_each = var.ssh_public_keys
    content {
      username   = var.admin_username
      public_key = file(admin_ssh_key.value)
    }
  }
  allow_extension_operations = "true"

  source_image_reference {
    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }

  os_disk {
    name                 = var.vm_hostname_override != "" ? join("-", [var.vm_hostname_override, count.index, "osdisk"]) : join("-", [module.naming.virtual_machine.name, count.index, "osdisk"])
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }

  tags = var.tags

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }
}

resource "azurerm_windows_virtual_machine" "vm-windows" {
  count                      = ((var.vm_os_id != "" && var.is_windows_image == "true") || contains(list(var.vm_os_simple, var.vm_os_offer), "WindowsServer")) ? var.nb_instances : 0
  name                       = var.vm_hostname_override != "" ? join("", [var.vm_hostname_override, count.index]) : join("", [module.naming.virtual_machine.name, count.index])
  resource_group_name        = data.azurerm_resource_group.vm.name
  location                   = data.azurerm_resource_group.vm.location
  availability_set_id        = var.availability_set == "true" ? azurerm_availability_set.vm[0].id : null
  size                       = var.vm_size
  network_interface_ids      = [element(azurerm_network_interface.vm.*.id, count.index)]
  computer_name              = var.vm_hostname_override != "" ? join("", [var.vm_hostname_override, count.index]) : join("", [module.naming.virtual_machine.name, count.index])
  admin_username             = var.admin_username
  admin_password             = var.admin_password
  allow_extension_operations = "true"

  # winrm_listener {
  #   Protocol = "Http"
  # }

  source_image_reference {
    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }

  os_disk {
    name                 = var.vm_hostname_override != "" ? join("-", [var.vm_hostname_override, count.index, "osdisk"]) : join("-", [module.naming.virtual_machine.name, count.index, "osdisk"])
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }

  # for azurerm_virtual_machine module
  # dynamic "storage_data_disk" {
  #   for_each = var.data_disks == null ? [] : var.data_disks
  #   iterator = disk
  #   content {
  #     name              = var.vm_hostname_override != "" ? join("-", [var.vm_hostname_override, count.index, "datadisk", disk.value.lun]) : join("-", [module.naming.virtual_machine.name, count.index, "datadisk", disk.value.lun])
  #     create_option     = disk.value.create_option
  #     lun               = disk.value.lun
  #     disk_size_gb      = disk.value.disk_size_gb
  #     managed_disk_type = disk.value.storage_account_type
  #     caching           = disk.value.caching
  #   }
  # }

  tags = var.tags

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }
}

resource "azurerm_managed_disk" "vm" {
  # local.vm_data_disks is a list, so we must now project it into a map
  # Each instance must have a unique key, so we'll construct one
  # by combining the vm_index, and lun.
  for_each = {
    for dd in local.vm_data_disks : "${dd.vm_index}.${dd.lun}" => dd
  }
  name                 = var.vm_hostname_override != "" ? join("-", [var.vm_hostname_override, each.value.vm_index, "datadisk", each.value.lun]) : join("-", [module.naming.virtual_machine.name, each.value.vm_index, "datadisk", each.value.lun])
  resource_group_name  = data.azurerm_resource_group.vm.name
  location             = data.azurerm_resource_group.vm.location
  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  disk_size_gb         = each.value.disk_size_gb

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm" {
  for_each = {
    for dd in local.vm_data_disks : "${dd.vm_index}.${dd.lun}" => dd
  }

  managed_disk_id    = azurerm_managed_disk.vm[each.key].id
  virtual_machine_id = ((var.vm_os_id != "" && var.is_windows_image == "true") || contains(list(var.vm_os_simple, var.vm_os_offer), "WindowsServer")) ? azurerm_windows_virtual_machine.vm-windows[each.value.vm_index].id : azurerm_linux_virtual_machine.vm-linux[each.value.vm_index].id
  lun                = each.value.lun
  caching            = each.value.caching
  depends_on         = [azurerm_managed_disk.vm]
}

resource "azurerm_availability_set" "vm" {
  count                        = var.availability_set == "true" ? 1 : 0
  name                         = var.vm_hostname_override != "" ? join("-", [var.vm_hostname_override, count.index]) : join("-", [module.naming.virtual_machine.name, "avset"])
  resource_group_name          = data.azurerm_resource_group.vm.name
  location                     = data.azurerm_resource_group.vm.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_public_ip" "vm" {
  count               = var.nb_public_ip
  name                = var.vm_hostname_override != "" ? join("-", [var.vm_hostname_override, count.index, "pip"]) : join("-", [module.naming.virtual_machine.name, count.index, "pip"])
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = data.azurerm_resource_group.vm.location
  allocation_method   = var.public_ip_address_allocation
  domain_name_label   = element(var.public_ip_dns, count.index)
}

resource "azurerm_network_interface" "vm" {
  count               = var.nb_instances
  name                = var.vm_hostname_override != "" ? join("-", [var.vm_hostname_override, count.index, "nic"]) : join("-", [module.naming.virtual_machine.name, count.index, "nic"])
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = data.azurerm_resource_group.vm.location

  ip_configuration {
    name                          = join("", ["ipconfig", count.index])
    subnet_id                     = data.azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, list("")), count.index) : ""
  }
}

resource "azurerm_network_interface_security_group_association" "vm" {
  count                     = var.nb_instances
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = data.azurerm_network_security_group.vm.id
}

resource "azurerm_virtual_machine_extension" "vm" {
  count = ((var.vm_os_id != "" && var.is_windows_image == "true") || contains(list(var.vm_os_simple, var.vm_os_offer), "WindowsServer")) ? var.nb_instances : 0

  name                 = "WinRM"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm-windows[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
  {
      "fileUris": [
          "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
      ],
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1 -DisableBasicAuth -GlobalHttpFirewallAccess"
  }
SETTINGS
}
