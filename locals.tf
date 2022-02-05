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

locals {
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  random_id           = random_string.id.result
  suffix              = coalesce(var.suffix, local.random_id)
  public_key          = var.public_key != "" ? var.public_key : tls_private_key.main[0].public_key_openssh
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.1.1"
  suffix  = [local.suffix]
}
