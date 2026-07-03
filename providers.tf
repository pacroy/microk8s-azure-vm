terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.80.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.6.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.1.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~>2.4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~>3.4.3"
    }
  }
  required_version = "~> 1.14"
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