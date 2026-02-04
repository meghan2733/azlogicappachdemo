terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstatechubbpoc"
    container_name       = "tfstate"
    key                  = "insurance-poc.tfstate"
  }
}
