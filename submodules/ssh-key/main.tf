resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key" {
  count    = var.public_ssh_key == "" ? 1 : 0
  content  = tls_private_key.ssh.private_key_pem
  filename = "./private_ssh_key"
}

# ## Save the private key in the local workspace ##
# resource "null_resource" "save-key" {
#   triggers = {
#     key = tls_private_key.ssh.private_key_pem
#   }

#   provisioner "local-exec" {
#     command = <<EOF
#       mkdir -p ${path.module}/.ssh
#       echo "${tls_private_key.ssh.private_key_pem}" > ${path.module}/.ssh/id_rsa
#       chmod 0600 ${path.module}/.ssh/id_rsa
# EOF
#   }
# }

output "public_ssh_key" {
  # Only output a generated ssh public key
  value = var.public_ssh_key != "" ? "" : tls_private_key.ssh.public_key_openssh
}

variable "public_ssh_key" {
  description = "An ssh key set in the main variables of the terraform-azurerm-aks module"
  default     = ""
}
