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
  use_oidc = true
}

# Resource Group
resource "azurerm_resource_group" "rg-terraform-state" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# # Storage Account for ACH files
# resource "azurerm_storage_account" "ach_storage" {
#   name                     = var.storage_account_name
#   resource_group_name      = azurerm_resource_group.ach_demo.name
#   location                 = azurerm_resource_group.ach_demo.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   min_tls_version          = "TLS1_2"

#   blob_properties {
#     versioning_enabled = true
#   }

#   tags = var.tags
# }

# # Blob Container for incoming ACH files
# resource "azurerm_storage_container" "ach_input" {
#   name                  = "ach-input"
#   storage_account_name  = azurerm_storage_account.ach_storage.name
#   container_access_type = "private"
# }

# # Blob Container for validated ACH files
# resource "azurerm_storage_container" "ach_validated" {
#   name                  = "ach-validated"
#   storage_account_name  = azurerm_storage_account.ach_storage.name
#   container_access_type = "private"
# }

# # Blob Container for failed validation ACH files
# resource "azurerm_storage_container" "ach_failed" {
#   name                  = "ach-failed"
#   storage_account_name  = azurerm_storage_account.ach_storage.name
#   container_access_type = "private"
# }

# # Logic App (Consumption Tier)
# resource "azurerm_resource_group_template_deployment" "ach_processor" {
#   name                = var.logic_app_name
#   # location            = azurerm_resource_group.ach_demo.location
#   resource_group_name = azurerm_resource_group.ach_demo.name
#   deployment_mode     = "Incremental"

#   # definition = jsonencode({
#   #   "$schema" = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
#   #   contentVersion = "1.0.0.0"
    
#   #   triggers = jsondecode(file("${path.module}/logic-app-workflow.json")).triggers
#   #   actions  = jsondecode(file("${path.module}/logic-app-workflow.json")).actions
#   # })
#   # definition = file("${path.module}/logic-app-workflow.json")
#   template_content = jsonencode({
#     "$schema" = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
#     contentVersion = "1.0.0.0"
#     parameters = {}
#     variables = {}
#     resources = [
#       {
#         type = "Microsoft.Logic/workflows"
#         apiVersion = "2019-05-01"
#         name = var.logic_app_name
#         location = azurerm_resource_group.ach_demo.location
#         properties = {
#           state = "Enabled"
#           definition = jsondecode(file("${path.module}/logic-app-workflow.json"))
#             parameters = {
#             "$connections" = {
#               value = {
#                 "azureblob_connection" = {  # Match the actual connection name
#                   connectionId   = "[resourceId('Microsoft.Web/connections', 'azureblob_connection')]"
#                   connectionName = "azureblob_connection"
#                   id             = "[subscriptionResourceId('Microsoft.Web/locations/managedApis', resourceGroup().location, 'azureblob')]"
#                 }
#               }
#             }
#           }
#         }
#       }
#     ]
#     outputs = {
#       logicAppUrl = {
#         type = "string"
#         value = "[listCallbackURL(concat(resourceId('Microsoft.Logic/workflows', 'logic-ach-processor'), '/triggers/manual'), '2019-05-01').value]"
#       }
#     }
#   })

#   tags = var.tags
# }

# # Logic App Trigger - Recurrence (3 minutes) - COMMENTED OUT FOR MANUAL EXECUTION
# # resource "azurerm_logic_app_trigger_recurrence" "poll_blob" {
# #   name         = "PollBlobEvery3Minutes"
# #   logic_app_id = azurerm_logic_app_workflow.ach_processor.id
# #   frequency    = "Minute"
# #   interval     = 3
# # }

# # API Connection for Azure Blob Storage
# resource "azurerm_api_connection" "blob_connection" {
#   name                = "azureblob_connection"
#   resource_group_name = azurerm_resource_group.ach_demo.name
#   managed_api_id      = data.azurerm_managed_api.azureblob_connection.id
#   display_name        = "Azure Blob Storage Connection"

#   parameter_values = {
#     accountName = azurerm_storage_account.ach_storage.name
#     accessKey   = azurerm_storage_account.ach_storage.primary_access_key
#   }

#   # Azure may encrypt or modify connection parameters after creation
#   # Ignore changes to prevent Terraform from detecting drift
#   lifecycle {
#     ignore_changes = [parameter_values]
#   }
# }

# # Data source for Azure Blob managed API
# data "azurerm_managed_api" "azureblob_connection" {
#   name     = "azureblob"
#   location = azurerm_resource_group.ach_demo.location
# }

# Role Assignment: User Access Administrator
resource "azurerm_role_assignment" "user_access_admin" {
  scope                = azurerm_resource_group.rg-terraform-state.id
  role_definition_name = "User Access Administrator"
  principal_id         = var.target_principal_id
}
