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
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_id" {
  description = "Web subnet ID"
  value       = azurerm_subnet.web.id
}

output "public_ip_address" {
  description = "The public IP address"
  value       = azurerm_public_ip.web.ip_address
}

output "network_interface_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.web.id
}

output "linux_vm_id" {
  description = "The ID of the Linux virtual machine"
  value       = azurerm_linux_virtual_machine.web.id
}

output "linux_vm_public_ip" {
  description = "The public IP address of the Linux virtual machine"
  value       = azurerm_linux_virtual_machine.web.public_ip_address
}