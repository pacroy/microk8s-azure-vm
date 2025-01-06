terraform {
  cloud {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.5.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0.4"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~>2.3.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "~>3.3.0"
    }
  }
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