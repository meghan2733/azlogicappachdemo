variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-ach-demo"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "storage_account_name" {
  description = "Name of the Azure Storage Account (must be globally unique, 3-24 lowercase alphanumeric characters)"
  type        = string
  default     = "stachfiledemo"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "logic_app_name" {
  description = "Name of the Azure Logic App"
  type        = string
  default     = "logic-ach-processor"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Demo"
    Purpose     = "ACH File Processing"
    ManagedBy   = "Terraform"
  }
}
