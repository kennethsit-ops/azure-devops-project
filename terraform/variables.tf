variable "rg_name" {
  description = "Resource Group Name."
  type        = string
  default     = "rg-devops-dev"
}

variable "location" {
  description = "Azure Region."
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Azure Storage Account Name."
  type        = string
  default     = "stdevops001"
}

variable "vnet_name" {
  description = "Virtual Network Name."
  type        = string
  default     = "vnet-devops-dev"
}

variable "vnet_address_space" {
  description = "Virtual Network Address Space."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name_web" {
  description = "Web Subnet Name."
  type        = string
  default     = "snet-web"
}

variable "subnet_address_prefixes_web" {
  description = "Subnet Address Prefix."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "nsg_name_web" {
  description = "Network Security Group Name."
  type        = string
  default     = "nsg-web"
}

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
}

variable "admin_username" {
  description = "Admin Username for the Virtual Machine."
  type        = string
  default     = "azureuser"
}

variable "acr_name" {
  description = "Azure Container Registry Name."
  type        = string
  default     = "acrdevops001"
}