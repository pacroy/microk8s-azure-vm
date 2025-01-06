terraform {
  cloud {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.6.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0.6"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~>2.3.5"
    }
    http = {
      source  = "hashicorp/http"
      version = "~>3.4.5"
    }
  }
  required_version = "~> 1.9.0"
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