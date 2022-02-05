variable "resource_group_name" {
  description = "Resource group name to provision all resources"
}

variable "suffix" {
  description = "Suffix of all resource names. Default is a 7-char random string."
  default     = ""
}