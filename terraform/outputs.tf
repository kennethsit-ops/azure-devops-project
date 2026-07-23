output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.rg.location
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.rg.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.storage.name
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = data.azurerm_virtual_network.existing.name
}

output "subnet_id" {
  description = "Web subnet ID"
  value       = data.azurerm_subnet.existing.id
}

output "acr_login_server" {
  description = "The login server of the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "existing_vnet_id" {
  description = "ID of the existing shared virtual network"
  value       = data.azurerm_virtual_network.existing.id
}

output "existing_subnet_id" {
  description = "ID of the existing shared subnet"
  value       = data.azurerm_subnet.existing.id
}

output "existing_vnet_address_space" {
  value = data.azurerm_virtual_network.existing.address_space
}

output "existing_subnet_address_prefixes" {
  value = data.azurerm_subnet.existing.address_prefixes
}

output "linux_vm_ids" {
  description = "IDs of all Linux Web virtual machines"

  value = {
    for name, vm in module.linux_vms :
    name => vm.vm_id
  }
}

output "linux_vm_public_ips" {
  description = "Public IP addresses of all Linux Web virtual machines"

  value = {
    for name, vm in module.linux_vms :
    name => vm.vm_public_ip
  }
}

output "linux_vms" {
  description = "Details of all Linux virtual machines (name, id, pip)"

  value = {
    for key, vm in module.linux_vms :
    key => {
      vm_name   = vm.vm_name
      vm_id     = vm.vm_id
      public_ip = vm.vm_public_ip
    }
  }
}
