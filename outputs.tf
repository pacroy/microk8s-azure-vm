output "resource_group" {
  value = data.azurerm_resource_group.main
}

output "suffix" {
  value = local.suffix
}

output "domain_name_label" {
  value = local.domain_name_label
}

output "public_key" {
  value = local.public_key
}

output "private_key" {
  value     = try(tls_private_key.main[0].private_key_pem, "")
  sensitive = true
}

output "network_security_group" {
  value = azurerm_network_security_group.default
}

output "virtual_network" {
  value = azurerm_virtual_network.main
}

output "linux_virtual_machine" {
  value     = azurerm_linux_virtual_machine.main
  sensitive = true
}
