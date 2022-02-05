resource "azurerm_network_security_group" "default" {
  name                = join(module.naming.network_security_group, ["-default"])
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
  name                       = join(module.naming.network_security_rule, ["-AllowControlFromIP"])
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
  name                       = join(module.naming.network_security_rule, ["-AllowHTTPsFromInternet"])
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-microk8s-nprd-01"
  resource_group_name = local.resource_group_name
  location            = local.location

  address_space = ["172.16.0.0/16"]
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.16.0.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_public_ip" "load_balancer" {
  name                = "pip-microk8s-nprd-01-lbe"
  resource_group_name = local.resource_group_name
  location            = local.location

  allocation_method = "Static"
  availability_zone = "No-Zone"
  domain_name_label = "fh7kxp6"
  sku               = "Standard"
  sku_tier          = "Regional"
  ip_version        = "IPv4"
}

resource "azurerm_network_interface" "vm_main" {
  name                = "vm-microk8s-nprd-660"
  resource_group_name = local.resource_group_name
  location            = local.location

  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-microk8s-nprd-01"
  resource_group_name = upper(local.resource_group_name)
  location            = local.location

  size                  = "Standard_D2s_v5"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm_main.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/dev/pacroy/microk8s-nprd-01/ssh-microk8s-nprd-01.pub")
  }

  boot_diagnostics {}

  os_disk {
    name                 = "vm-microk8s-nprd-01_OsDisk_1_3489dc4012f34b6e9666cb338e688ce5"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "canonical"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}
