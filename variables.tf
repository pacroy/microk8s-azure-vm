variable "resource_group_name" {
  description = "Resource group name to provision all resources"
  type        = string
}

variable "ip_address" {
  description = "IP address or range to allow access to the control ports of the VM. Default value is your public IP address."
  type        = string
  default     = ""
}

variable "location" {
  description = "The location to provision all resources. Omit to use the same location as the resource group."
  type        = string
  default     = ""
}

variable "email" {
  description = "Email address for receiving notifications from Let's Encrypt. Default "
  type        = string
  default     = ""
}

variable "suffix" {
  description = "Suffix of all resource names. Default is a 7-char random string."
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "Admin username of the porvisioning VM."
  type        = string
  default     = "azureuser"
}

variable "address_space" {
  description = "Virtual netowrk address space in CIDR range."
  type        = string
  default     = "172.16.0.0/16"
}

variable "size" {
  description = "Virtual machine size."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "allow_kubectl_from_azurecloud" {
  description = "Whether to add an inbound rule to allow kubectl from AzureCloud when connecting from GitHub Actions or Azure Pipelines."
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Whether to install cert-manager and Let's Encrypt cluster issuer."
  type        = bool
  default     = true
}