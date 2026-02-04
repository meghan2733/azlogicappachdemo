terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "ach_demo" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Storage Account for ACH files
resource "azurerm_storage_account" "ach_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.ach_demo.name
  location                 = azurerm_resource_group.ach_demo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

# Blob Container for incoming ACH files
resource "azurerm_storage_container" "ach_input" {
  name                  = "ach-input"
  storage_account_name  = azurerm_storage_account.ach_storage.name
  container_access_type = "private"
}

# Blob Container for validated ACH files
resource "azurerm_storage_container" "ach_validated" {
  name                  = "ach-validated"
  storage_account_name  = azurerm_storage_account.ach_storage.name
  container_access_type = "private"
}

# Blob Container for failed validation ACH files
resource "azurerm_storage_container" "ach_failed" {
  name                  = "ach-failed"
  storage_account_name  = azurerm_storage_account.ach_storage.name
  container_access_type = "private"
}

# Logic App (Consumption Tier)
resource "azurerm_logic_app_workflow" "ach_processor" {
  name                = var.logic_app_name
  location            = azurerm_resource_group.ach_demo.location
  resource_group_name = azurerm_resource_group.ach_demo.name

  tags = var.tags
}

# Logic App Trigger - Recurrence (3 minutes)
resource "azurerm_logic_app_trigger_recurrence" "poll_blob" {
  name         = "PollBlobEvery3Minutes"
  logic_app_id = azurerm_logic_app_workflow.ach_processor.id
  frequency    = "Minute"
  interval     = 3
}

# API Connection for Azure Blob Storage
resource "azurerm_api_connection" "blob_connection" {
  name                = "azureblob-connection"
  resource_group_name = azurerm_resource_group.ach_demo.name
  managed_api_id      = data.azurerm_managed_api.azureblob.id
  display_name        = "Azure Blob Storage Connection"

  parameter_values = {
    accountName = azurerm_storage_account.ach_storage.name
    accessKey   = azurerm_storage_account.ach_storage.primary_access_key
  }

  lifecycle {
    ignore_changes = [parameter_values]
  }
}

# Data source for Azure Blob managed API
data "azurerm_managed_api" "azureblob" {
  name     = "azureblob"
  location = azurerm_resource_group.ach_demo.location
}
