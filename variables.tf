variable "resource_group_name" {
  description = "Resource group name to provision all resources"
}

variable "suffix" {
  description = "Suffix of all resource names. Default is a 7-char random string."
  default     = ""
}

variable "public_key" {
  description = "SSH public key. Can be generated with ssh-keygen -t rsa -b 4096 -f id_rsa -N \"\" -C \"microk8s\"."
  default     = ""
}