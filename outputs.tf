output "resource_group" {
  value = data.azurerm_resource_group.main
}

output "suffix" {
  value = local.suffix
}

output "public_key" {
  value = local.public_key
}

output "private_key" {
  value     = var.public_key ? "" : tls_private_key.main[0].private_key_pem
  sensitive = true
}

output "network_security_group" {
  value = azurerm_network_security_group.default
}

output "virtual_network" {
  value = azurerm_virtual_network.main
}