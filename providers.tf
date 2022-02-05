terraform {
  required_providers {
    azurerm = {
      version = "~>2.95.0"
    }
  }
  #   backend "azurerm" {}
}

provider "azurerm" {
  features {}
}
