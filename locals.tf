data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "random_string" "instance_id" {
  length  = 7
  special = false
}

locals {
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
  instance_id         = random_string.instance_id.result
  instance_name       = coalesce(var.instance_name, "microk8s-${local.instance_id}")
}
