resource "azurerm_network_security_group" "default" {
  name                = "nsg-microk8s-nprd-01-default"
  location            = "southeastasia"
  resource_group_name = local.resource_group_name
  security_rule = [
    {
      access                                     = "Allow"
      description                                = ""
      destination_address_prefix                 = "*"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = ""
      destination_port_ranges = [
        "16443",
        "22",
      ]
      direction                             = "Inbound"
      name                                  = "AllowControlFromIP"
      priority                              = 120
      protocol                              = "TCP"
      source_address_prefix                 = "49.49.236.16"
      source_address_prefixes               = []
      source_application_security_group_ids = []
      source_port_range                     = "*"
      source_port_ranges                    = []
    },
    {
      access                                     = "Allow"
      description                                = ""
      destination_address_prefix                 = "*"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = ""
      destination_port_ranges = [
        "30219",
        "31498",
      ]
      direction                             = "Inbound"
      name                                  = "AllowHTTPsFromInternet"
      priority                              = 130
      protocol                              = "TCP"
      source_address_prefix                 = "Internet"
      source_address_prefixes               = []
      source_application_security_group_ids = []
      source_port_range                     = "*"
      source_port_ranges                    = []
    },
  ]
}
