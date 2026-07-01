output "resource_group_name" {
  description = "The name of the resource group"
  value = azurerm_resource_group.rg.name
}

output "location" {
  description = "The location of the resource group"
  value = azurerm_resource_group.rg.location
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value = azurerm_resource_group.rg.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value = azurerm_storage_account.storage.name
}