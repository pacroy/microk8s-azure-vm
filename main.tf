resource "azurerm_network_security_group" "default" {
  name                = join("-", [module.naming.network_security_group.name, "default"])
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

resource "azurerm_virtual_network" "main" {
  name                = module.naming.virtual_network.name
  resource_group_name = local.resource_group_name
  location            = local.location

  address_space = ["172.16.0.0/16"]

  subnet {
    name           = "default"
    address_prefix = "172.16.0.0/24"
    security_group = azurerm_network_security_group.default.id
  }
}

resource "azurerm_network_interface" "vm_main" {
  name                = module.naming.network_interface.name
  resource_group_name = local.resource_group_name
  location            = local.location

  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = one(azurerm_virtual_network.main.subnet).id
    private_ip_address_allocation = "Dynamic"
  }
}

# resource "azurerm_linux_virtual_machine" "main" {
#   name                = "vm-microk8s-nprd-01"
#   resource_group_name = upper(local.resource_group_name)
#   location            = local.location

#   size                  = "Standard_D2s_v5"
#   admin_username        = "azureuser"
#   network_interface_ids = [azurerm_network_interface.vm_main.id]

#   admin_ssh_key {
#     username   = "azureuser"
#     public_key = file("~/dev/pacroy/microk8s-nprd-01/ssh-microk8s-nprd-01.pub")
#   }

#   boot_diagnostics {}

#   os_disk {
#     name                 = "vm-microk8s-nprd-01_OsDisk_1_3489dc4012f34b6e9666cb338e688ce5"
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#   }

#   source_image_reference {
#     offer     = "0001-com-ubuntu-server-focal"
#     publisher = "canonical"
#     sku       = "20_04-lts-gen2"
#     version   = "latest"
#   }
# }
