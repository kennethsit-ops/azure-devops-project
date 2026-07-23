variable "environment" {
  description = "Environment."
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name."
  type        = string
}

variable "location" {
  description = "Azure Region."
  type        = string
}

variable "storage_account_name" {
  description = "Azure Storage Account Name."
  type        = string
  default     = "stdevops001"
}

variable "network_resource_group_name" {
  description = "Resource group containing the existing virtual network"
  type        = string
}

variable "existing_vnet_name" {
  description = "Name of the existing virtual network"
  type        = string
}

variable "existing_subnet_name" {
  description = "Name of the existing subnet"
  type        = string
}

/* variable "vnet_name" {
  description = "Virtual Network Name."
  type        = string
  default     = "vnet-devops"
}

variable "subnet_name_web" {
  description = "Web Subnet Name."
  type        = string
  default     = "snet-web"
} */

variable "nsg_name_web" {
  description = "Network Security Group Name."
  type        = string
  default     = "nsg-web"
}
/* 
variable "public_ip_name_web" {
  description = "Public IP Name."
  type        = string
  default     = "pip-web"
}

variable "nic_name_web" {
  description = "Network Interface Name."
  type        = string
  default     = "nic-web"
}

variable "vm_name_web" {
  description = "Virtual Machine Name."
  type        = string
  default     = "vmweb01"
}

variable "vm_size_web" {
  description = "Virtual Machine Size."
  type        = string
  default     = "Standard_D2s_v7"
} */

variable "admin_username" {
  description = "Admin Username for the Virtual Machine."
  type        = string
}

variable "acr_name" {
  description = "Azure Container Registry Name."
  type        = string
  default     = "acrdevops001"
}

variable "linux_vms" {
  description = "Configuration for Linux virtual machines"

  type = map(object({
    #vm_name        = string
    #nic_name       = string
    #public_ip_name = string
    vm_size          = string
    enable_public_ip = optional(bool, false)
  }))
}