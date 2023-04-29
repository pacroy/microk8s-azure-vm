data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "random_string" "first_character" {
  length  = 1
  special = false
  upper   = false
  numeric = false
}

resource "random_string" "six_character" {
  length  = 6
  special = false
  upper   = false
}

resource "random_integer" "ssh" {
  min = 20000
  max = 24999
}

resource "random_integer" "ssh_vm" {
  min = 10001
  max = 16442
}

resource "random_integer" "kubectl" {
  min = 25000
  max = 29999
}

resource "random_integer" "http" {
  min = 30000
  max = 31999
}

resource "random_integer" "https" {
  min = 32000
  max = 32767
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

data "cloudinit_config" "init" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/init.cfg.tftpl", {
      admin_username      = local.admin_username
      fqdn                = azurerm_public_ip.main.fqdn
      public_ip           = azurerm_public_ip.main.ip_address
      http_port           = local.http_port
      https_port          = local.https_port
      email               = local.email
      ssh_vm_port         = local.ssh_vm_port
      enable_cert_manager = local.enable_cert_manager
    })
  }
}

data "http" "ip_address" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  resource_group_name = var.resource_group_name
  location            = coalesce(var.location, data.azurerm_resource_group.main.location)
  random_id           = "${random_string.first_character.result}${random_string.six_character.result}"
  suffix              = coalesce(var.suffix, local.random_id)
  public_key          = tls_private_key.main.public_key_openssh
  admin_username      = var.admin_username
  domain_name_label   = local.random_id
  ssh_port            = random_integer.ssh.result
  kubectl_port        = random_integer.kubectl.result
  http_port           = random_integer.http.result
  https_port          = random_integer.https.result
  address_space       = var.address_space
  size                = var.size
  email               = coalesce(var.email, "${local.random_id}@mailinator.com")
  ssh_vm_port         = random_integer.ssh_vm.result
  enable_cert_manager = var.enable_cert_manager

  ip_address      = var.ip_address_list != null ? null : coalesce(var.ip_address, chomp(data.http.ip_address.response_body))
  ip_address_list = var.ip_address_list
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.2.0"
  suffix  = [local.suffix]
}
