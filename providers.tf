terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.95.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>3.1.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
  }
  #   backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "random" {
}

provider "tls" {
}

provider "cloudinit" {
}

provider "http" {
}