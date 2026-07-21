output "vm_id" {
  description = "The ID of the Linux virtual machine"
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_public_ip" {
  description = "The public IP address of the Linux virtual machine"
  value       = azurerm_linux_virtual_machine.this.public_ip_address
}

output "vm_name" {
  description = "Name of the Linux virtual machine"
  value       = azurerm_linux_virtual_machine.this.name
}