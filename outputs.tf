output "resource_group_name" {
  value = local.resource_group_name
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