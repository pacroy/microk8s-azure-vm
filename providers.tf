terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.7.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.1.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~>2.3.7"
    }
    http = {
      source  = "hashicorp/http"
      version = "~>3.5.0"
    }
  }
  required_version = "~>1.13"
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