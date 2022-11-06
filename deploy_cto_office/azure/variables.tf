variable "azurerm_resource_group_name" {
  type    = string
  default = "your-resource-group"
}

variable "dsf_vnet" {
  type    = string
  default = "your-vnet-name"
}

variable "security_group_ingress_cidrs" {
  type        = list(any)
  description = "List of allowed ingress cidr patterns for the DSF agentless gw instance"
  default     = ["1.2.3.4/32", "172.20.0.0/16"]
}

variable "storage_account" {
  type = string
  description = "Azure Storage Account for installation files download"
  default = "your-storage-account"
}

variable "storage_container" {
  type = string
  description = "Azure Storage Container for installation files download"
  default = "your-storage-container"
}

variable "dsf_install_tarball" {
  type = string
  description = "Azure Storage Container for installation files download"
  default = "jsonar-4.x_12345.tar.gz"
}
