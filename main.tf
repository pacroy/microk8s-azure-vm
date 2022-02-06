resource "azurerm_network_security_group" "default" {
  name                = join("-", [module.naming.network_security_group.name, "default"])
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_network_security_rule" "allow_control" {
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.default.name

  direction                  = "Inbound"
  source_address_prefix      = local.ip_address
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
  destination_port_ranges    = [local.http_port, local.https_port]
  protocol                   = "TCP"
  access                     = "Allow"
  priority                   = 110
  name                       = "AllowHTTPsFromInternet"
}

resource "azurerm_virtual_network" "main" {
  name                = module.naming.virtual_network.name
  resource_group_name = local.resource_group_name
  location            = local.location

  address_space = [local.address_space]

  subnet {
    name           = "default"
    address_prefix = cidrsubnet(local.address_space, 8, 0)
    security_group = azurerm_network_security_group.default.id
  }
}

resource "azurerm_network_interface" "main" {
  name                = module.naming.network_interface.name
  resource_group_name = local.resource_group_name
  location            = local.location

  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = one(azurerm_virtual_network.main.subnet).id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(cidrsubnet(one(azurerm_virtual_network.main.subnet).address_prefix, 8, 0), 4)
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = module.naming.linux_virtual_machine.name
  resource_group_name = local.resource_group_name
  location            = local.location

  size                  = local.size
  admin_username        = local.admin_username
  network_interface_ids = [azurerm_network_interface.main.id]

  admin_ssh_key {
    username   = local.admin_username
    public_key = local.public_key
  }

  boot_diagnostics {}

  os_disk {
    name                 = join("-", ["osdisk", module.naming.linux_virtual_machine.name])
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "canonical"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  custom_data = data.cloudinit_config.init.rendered
}
