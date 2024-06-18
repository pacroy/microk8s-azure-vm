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
  source_address_prefixes    = local.ip_address_list
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_ranges    = [local.ssh_vm_port, "16443"]
  protocol                   = "Tcp"
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
  protocol                   = "Tcp"
  access                     = "Allow"
  priority                   = 110
  name                       = "AllowHTTPsFromInternet"
}

resource "azurerm_network_security_rule" "allow_azurecloud" {
  count                       = var.allow_kubectl_from_azurecloud ? 1 : 0
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.default.name

  direction                  = "Inbound"
  source_address_prefix      = "AzureCloud"
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_ranges    = [local.ssh_vm_port, "16443"]
  protocol                   = "Tcp"
  access                     = "Allow"
  priority                   = 120
  name                       = "AllowControlFromAzureCloud"
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
  name                           = module.naming.network_interface.name
  resource_group_name            = local.resource_group_name
  location                       = local.location
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = one(azurerm_virtual_network.main.subnet).id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(one(azurerm_virtual_network.main.subnet).address_prefix, 4)
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = module.naming.linux_virtual_machine.name
  resource_group_name = local.resource_group_name
  location            = local.location

  size                       = local.size
  admin_username             = local.admin_username
  network_interface_ids      = [azurerm_network_interface.main.id]
  encryption_at_host_enabled = true
  provision_vm_agent         = true

  patch_mode                                             = "AutomaticByPlatform"
  patch_assessment_mode                                  = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true

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


resource "azurerm_maintenance_configuration" "main" {
  name                     = "mc-${local.suffix}"
  resource_group_name      = local.resource_group_name
  location                 = local.location
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"

  window {
    start_date_time = "2024-06-13 00:00"
    duration        = "01:30"
    time_zone       = "UTC"
    recur_every     = "Day"
  }
  install_patches {
    reboot = "IfRequired"
    linux {
      classifications_to_include = ["Critical", "Security"]
    }
  }
}

resource "azurerm_maintenance_assignment_virtual_machine" "main" {
  location                     = local.location
  maintenance_configuration_id = azurerm_maintenance_configuration.main.id
  virtual_machine_id           = azurerm_linux_virtual_machine.main.id
}