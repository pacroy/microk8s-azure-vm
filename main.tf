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

resource "azurerm_lb" "main" {
  name                = "lbe-microk8s-nprd-01"
  resource_group_name = upper(local.resource_group_name)
  location            = local.location

  sku      = "Standard"
  sku_tier = "Regional"

  frontend_ip_configuration {
    availability_zone    = "No-Zone"
    name                 = "pip-microk8s-nprd-01-lbe"
    public_ip_address_id = azurerm_public_ip.load_balancer.id
    # load_balancer_rules = [
    #   azurerm_lb_rule.ssh.id,
    #   azurerm_lb_rule.kubectl.id,
    #   azurerm_lb_rule.http.id,
    #   azurerm_lb_rule.https.id,
    # ]
    # outbound_rules = [
    #   azurerm_lb_outbound_rule.internet.id,
    # ]
  }
}

resource "azurerm_lb_backend_address_pool" "vm_main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "vm-microk8s-nprd-01"
}

resource "azurerm_lb_outbound_rule" "internet" {
  resource_group_name     = local.resource_group_name
  loadbalancer_id         = azurerm_lb.main.id
  name                    = "rule-outbound"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.vm_main.id

  frontend_ip_configuration {
    name = azurerm_lb.main.frontend_ip_configuration[0].name
  }
}

resource "azurerm_lb_probe" "vm_main" {
  resource_group_name = local.resource_group_name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "ssh"
  protocol            = "Tcp"
  port                = 22
}

resource "azurerm_lb_rule" "ssh" {
  resource_group_name = local.resource_group_name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "rule-ssh"

  protocol                       = "Tcp"
  frontend_port                  = 21648
  backend_port                   = 22
  frontend_ip_configuration_name = azurerm_lb.main.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.vm_main.id
}

resource "azurerm_lb_rule" "kubectl" {
  resource_group_name = local.resource_group_name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "rule-kubectl"

  protocol                       = "Tcp"
  frontend_port                  = 31659
  backend_port                   = 16443
  frontend_ip_configuration_name = azurerm_lb.main.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.vm_main.id
}

resource "azurerm_lb_rule" "http" {
  resource_group_name = local.resource_group_name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "rule-http"

  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 30219
  frontend_ip_configuration_name = azurerm_lb.main.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.vm_main.id
}

resource "azurerm_lb_rule" "https" {
  resource_group_name = local.resource_group_name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "rule-https"

  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 31498
  frontend_ip_configuration_name = azurerm_lb.main.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.vm_main.id
}
