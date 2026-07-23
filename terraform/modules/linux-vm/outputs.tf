output "vm_id" {
  description = "The ID of the Linux virtual machine"
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_public_ip" {
  description = "Public IP address of the VM, if enabled"

  value = (
    var.enable_public_ip
    ? azurerm_public_ip.this[0].ip_address
    : null
  )
}

output "vm_name" {
  description = "Name of the Linux virtual machine"
  value       = azurerm_linux_virtual_machine.this.name
}