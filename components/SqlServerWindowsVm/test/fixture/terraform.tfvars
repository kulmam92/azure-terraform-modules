component          = "VMTest"
product            = "VMTest"
environment        = "Sandbox"
datacenter         = "WestUS2"
location           = "WestUS2"
account_short_name = "vmt"
tags = {
  DataCenter    = "WestUS2"
  Environment   = "Sandbox"
  Terraform     = true
  TerraformPath = "components/SqlServerWindowsVM/test"
}

networking_object = {
  vnet = {
    name_overwrite  = null
    address_space   = ["10.20.228.0/22"]
    dns             = []
    enable_ddos_std = false
    ddos_id         = null
  }
  subnets = {
    subnet1 = {
      name_postfix                                   = "Database"
      cidr                                           = ["10.20.228.0/26"]
      service_endpoints                              = ["Microsoft.Storage", "Microsoft.KeyVault"]
      enforce_private_link_endpoint_network_policies = null
      enforce_private_link_service_network_policies  = null
      nsg_name_postfix                               = "Database"
      nsg = [
        # RDP
        {
          name                       = "Allow-RDP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3389"
          source_address_prefix      = "<My IP Address>"
          destination_address_prefix = "*"
        },
        # WinRM - HTTP/HTTPS
        {
          name                       = "Allow-WinRM"
          priority                   = 101
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "5985-5986"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        # ssh
        {
          name                       = "Allow-ssh"
          priority                   = 102
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "<My IP Address>"
          destination_address_prefix = "*"
        },
        # MSSQL
        {
          name                       = "Allow-ms-sql"
          priority                   = 103
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "<My IP Address>"
          destination_address_prefix = "*"
        }
      ]
      delegation = null
    }
  }
}
public_ip_dns = ["terrasqlvmip"]
nb_public_ip  = "1"
remote_port   = "3389"
nb_instances  = "1"
# windows
admin_password  = "ComplxP@ssw0rd!"
vm_os_publisher = "MicrosoftWindowsServer"
vm_os_offer     = "WindowsServer"
vm_os_sku       = "2019-Datacenter"
# # linux
# ssh_public_keys       = ["~/.ssh/id_rsa.pub"]
# vm_os_publisher       = "OpenLogic"
# vm_os_offer           = "CentOS"
# vm_os_sku             = "8_1-gen2"
vm_size          = "Standard_D2s_v4"
boot_diagnostics = "true"
data_disks = [
  # data
  {
    lun                  = 10
    disk_size_gb         = "100"
    caching              = "ReadOnly"
    storage_account_type = "Premium_LRS"
    create_option        = "Empty"
  },
  {
    lun                  = 11
    disk_size_gb         = "100"
    caching              = "ReadOnly"
    storage_account_type = "Premium_LRS"
    create_option        = "Empty"
  },
  # log
  {
    lun                  = 20
    disk_size_gb         = "100"
    caching              = "None"
    storage_account_type = "Premium_LRS"
    create_option        = "Empty"
  },
  {
    lun                  = 21
    disk_size_gb         = "100"
    caching              = "None"
    storage_account_type = "Premium_LRS"
    create_option        = "Empty"
  },
  # # temp
  # {
  #   lun                  = 30
  #   disk_size_gb         = "100"
  #   caching              = "None"
  #   storage_account_type = "Premium_LRS"
  #   create_option        = "Empty"
  # },
  # {
  #   lun                  = 31
  #   disk_size_gb         = "100"
  #   caching              = "None"
  #   storage_account_type = "Premium_LRS"
  #   create_option        = "Empty"
  # },
  # # backup
  # {
  #   lun                  = 40
  #   disk_size_gb         = "100"
  #   caching              = "None"
  #   storage_account_type = "Premium_LRS"
  #   create_option        = "Empty"
  # }
]
storage_pool = [
  {
    resource_name = "StoragePool"
    friendly_name = "DATA"
    drive_letter  = "F"
    luns          = ["10", "11"]
  },
  {
    resource_name = "StoragePool"
    friendly_name = "LOG"
    drive_letter  = "G"
    luns          = ["20", "21"]
  }
]
