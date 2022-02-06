data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "random_string" "id" {
  length  = 7
  special = false
  upper   = false
}

resource "random_integer" "ssh" {
  min = 20000
  max = 24999
}

resource "random_integer" "kubectl" {
  min = 25000
  max = 29999
}

resource "random_integer" "http" {
  min = 30000
  max = 34999
}

resource "random_integer" "https" {
  min = 35000
  max = 39999
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
    content      = templatefile("${path.module}/init.cfg.tftpl", { admin_username = local.admin_username })
  }
}

locals {
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  random_id           = random_string.id.result
  suffix              = coalesce(var.suffix, local.random_id)
  public_key          = tls_private_key.main.public_key_openssh
  ip_address          = var.ip_address
  admin_username      = var.admin_username
  domain_name_label   = local.random_id
  ssh_port            = random_integer.ssh.result
  kubectl_port        = random_integer.kubectl.result
  http_port           = random_integer.http.result
  https_port          = random_integer.https.result
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.1.1"
  suffix  = [local.suffix]
}
