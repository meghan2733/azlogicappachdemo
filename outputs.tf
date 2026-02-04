output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.ach_demo.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.ach_storage.name
}

output "storage_account_primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.ach_storage.primary_connection_string
  sensitive   = true
}

output "blob_container_input" {
  description = "Name of the input blob container"
  value       = azurerm_storage_container.ach_input.name
}

output "blob_container_validated" {
  description = "Name of the validated blob container"
  value       = azurerm_storage_container.ach_validated.name
}

output "blob_container_failed" {
  description = "Name of the failed blob container"
  value       = azurerm_storage_container.ach_failed.name
}

output "logic_app_name" {
  description = "Name of the Logic App"
  value       = azurerm_logic_app_workflow.ach_processor.name
}

output "logic_app_id" {
  description = "ID of the Logic App"
  value       = azurerm_logic_app_workflow.ach_processor.id
}

output "logic_app_access_endpoint" {
  description = "Logic App access endpoint URL"
  value       = azurerm_logic_app_workflow.ach_processor.access_endpoint
}

output "logic_app_callback_url" {
  description = "Logic App Callback Url"
  value     = jsondecode(azurerm_resource_group_template_deployment.logic_app.output_content).logicAppUrl.value
}
