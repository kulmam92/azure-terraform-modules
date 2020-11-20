variable "vm_os_simple" {
  default = ""
}

# Definition of the standard OS with "SimpleName" = "publisher,offer,sku"
variable "standard_os" {
  default = {
    "UbuntuServer"  = "Canonical,UbuntuServer,18.04-LTS"
    "WindowsServer" = "MicrosoftWindowsServer,WindowsServer,2019-Datacenter"
    "CentOS"        = "OpenLogic,CentOS,8_1-gen2"
    #     "RHEL"          = "RedHat,RHEL,77-gen2"
    #     "openSUSE-Leap" = "SUSE,openSUSE-Leap,42.2"
    #     "Debian"        = "credativ,Debian,8"
    #     "CoreOS"        = "CoreOS,CoreOS,Stable"
    #     "SLES"          = "SUSE,SLES,12-SP2"
  }
}
