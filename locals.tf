data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

locals {
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.main.location
}
