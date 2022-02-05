resource "azurerm_network_security_group" "default" {
  name                = "nsg-microk8s-nprd-01-default"
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_network_security_rule" "allow_control" {
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.default.name

  direction                  = "Inbound"
  source_address_prefix      = "49.49.236.16"
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_ranges    = ["22", "16443"]
  protocol                   = "TCP"
  access                     = "Allow"
  priority                   = 100
  name                       = "AllowControlFromIP"
}

resource "azurerm_network_security_rule" "allow_https" {
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.default.name

  direction                  = "Inbound"
  source_address_prefix      = "Internet"
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_ranges    = ["30219", "31498"]
  protocol                   = "TCP"
  access                     = "Allow"
  priority                   = 110
  name                       = "AllowHTTPsFromInternet"
}

resource "azurerm_public_ip" "load_balancer" {
  name                = "pip-microk8s-nprd-01-lbe"
  resource_group_name = local.resource_group_name
  location            = local.location
  
  allocation_method   = "Static"
  availability_zone   = "No-Zone"
  domain_name_label   = "fh7kxp6"
  sku                 = "Standard"
  sku_tier            = "Regional"
  ip_version          = "IPv4"
}