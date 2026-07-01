variable "rg_name" {
  description = "Azure Resource Group Name."
  type        = string
  default     = "rg-devops-dev"
}

variable "location" {
  description = "Azure Region."
  type        = string
  default     = "Canada Central"
}

variable "storage_account_name" {
  description = "Azure Storage Account Name."
  type        = string
  default     = "stdevops001"
}