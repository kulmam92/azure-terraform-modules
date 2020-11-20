output "vm_ids" {
  description = "Virtual machine ids created."
  value       = module.vm_windows.vm_ids
}

output "network_interface_ids" {
  description = "ids of the vm nics provisoned."
  value       = module.vm_windows.network_interface_ids
}

output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = module.vm_windows.network_interface_private_ip
}

output "availability_set_id" {
  description = "id of the availability set where the vms are provisioned."
  value       = module.vm_windows.availability_set_id
}

/* optionally, retrieve public IP properties
output "public_ip_id" {
  description = "id of the public ip address provisoned."
  value       = module.vm_windows.public_ip_id
}
*/
output "public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = module.vm_windows.public_ip_address
}

output "public_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value       = module.vm_windows.public_ip_dns_name
}

### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("${path.module}/inventory.tmpl",
    {
      # private-dns = module.vm_windows.public_ip_dns_name,
      public-dns = module.vm_windows.public_ip_dns_name,
      public-ip  = module.vm_windows.public_ip_address,
      private-ip = module.vm_windows.network_interface_private_ip,
      private-id = module.vm_windows.vm_ids
    }
  )
  filename = "inventory"
}
