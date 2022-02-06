data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "random_string" "id" {
  length  = 7
  special = false
  upper   = false
}

resource "tls_private_key" "main" {
  count     = var.public_key != "" ? 0 : 1
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
  public_key          = var.public_key != "" ? var.public_key : tls_private_key.main[0].public_key_openssh
  ip_address          = var.ip_address
  admin_username      = var.admin_username
  domain_name_label   = local.random_id
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.1.1"
  suffix  = [local.suffix]
}
