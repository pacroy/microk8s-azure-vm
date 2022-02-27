variable "resource_group_name" {
  description = "Resource group name to provision all resources"
}

variable "ip_address" {
  description = "IP address or range to allow access to the control ports of the VM. You may use `curl -s ipv4.icanhazip.com` to find your outbound public IP."
}

variable "location" {
  description = "The location to provision all resources. Omit to use the same location as the resource group."
  default     = ""
}

variable "email" {
  description = "Email address for receiving notifications from Let's Encrypt."
}

variable "suffix" {
  description = "Suffix of all resource names. Default is a 7-char random string."
  default     = ""
}

variable "admin_username" {
  description = "Admin username of the porvisioning VM."
  default     = "azureuser"
}

variable "address_space" {
  description = "Virtual netowrk address space in CIDR range."
  default     = "172.16.0.0/16"
}

variable "size" {
  description = "Virtual machine size."
  default     = "Standard_D2s_v5"
}

variable "allow_kubectl_from_azurecloud" {
  description = "Whether to add an inbound rule to allow kubectl from AzureCloud when connecting from GitHub Actions or Azure Pipelines."
  default     = true
}