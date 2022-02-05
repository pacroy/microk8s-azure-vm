output "resource_group" {
  value = data.azurerm_resource_group.main
}

output "suffix" {
  value = local.suffix
}

output "network_security_group" {
  value = azurerm_network_security_group.default
}

output "virtual_network" {
  value = azurerm_virtual_network.main
}