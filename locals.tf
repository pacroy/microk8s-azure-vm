data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "random_string" "id" {
  length  = 7
  special = false
  upper   = false
}

locals {
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  random_id           = random_string.id.result
  suffix              = coalesce(var.suffix, local.random_id)
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.1.1"
  suffix  = [local.suffix]
}
