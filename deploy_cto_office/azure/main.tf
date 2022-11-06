terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.56.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "vnet" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = var.azurerm_resource_group_name
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]
  vnet_name           = var.dsf_vnet
}

data "template_file" "hub_cloudinit" {
  template = file("${path.module}/hub_cloudinit.tpl")
  vars = {
    name                  = var.name
    dsf_install_tarball   = var.dsf_install_tarball
    storage_account       = var.storage_account
    storage_container     = var.storage_container
  }
}

module "linuxservers" {
  source                  = "Azure/compute/azurerm"
  resource_group_name     = var.azurerm_resource_group_name
  vm_hostname             = "dsf-hub"
  nb_public_ip            = 1
  allocation_method       = "Static"
  vm_os_offer             = "CentOS"
  vm_os_publisher         = "OpenLogic"
  vm_os_sku               = "7_9"
  remote_port             = "22"
  vnet_subnet_id          = module.vnet.vnet_subnets[0]
  custom_data             = filebase64(data.template_file.hub_cloudinit.rendered)
  vm_size                 = "Standard_F2"
  storage_account_type    = "StandardSSD_LRS"
  source_address_prefixes = var.security_group_ingress_cidrs
  admin_username          = "dsf_admin"
  delete_os_disk_on_termination = true
  identity_type = "SystemAssigned"

}

data "azurerm_storage_account" "dsf_installation_files_storage" {
  name                = var.storage_account
  resource_group_name = var.azurerm_resource_group_name
}

resource "azurerm_role_assignment" "storage" {
    scope = data.azurerm_storage_account.dsf_installation_files_storage.id
    role_definition_name = "Storage Blob Data Reader"
    principal_id = values(module.linuxservers.vm_identity)[0][0].principal_id

}

output "dsf_vm_public_address" {
  value = module.linuxservers.public_ip_address
}


