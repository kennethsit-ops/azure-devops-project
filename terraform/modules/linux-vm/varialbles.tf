variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "public_ip_name" {
  description = " Public IP Name for the VM."
  type        = string
}

variable "nic_name" {
  description = "Network Interface Name."
  type        = string
}

variable "location" {
  description = "Azure Region for the VM."
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the VM."
  type        = string
}

variable "vm_name" {
  description = "Virtual Machine Name."
  type        = string
}

variable "vm_size" {
  description = "Virtual Machine Size."
  type        = string
default     = "Standard_D2s_v7"
}

variable "admin_username" {
  description = "Admin Username for the VM."
  type        = string
  default     = "azureuser"
}

variable "custom_data" {
  description = "Base64-encoded cloud-init data"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key used to access the Linux VM"
  type        = string
  sensitive   = true
}