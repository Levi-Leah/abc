# Define the resource group for Terraform state storage
resource "azurerm_resource_group" "tfstate" {
    name     = var.storage_resource_group_name
    location = var.location
}

# Create the storage account for the state file
resource "azurerm_storage_account" "tfstate_storage" {
    name                      = var.storage_account_name
    resource_group_name       = azurerm_resource_group.tfstate.name
    location                  = azurerm_resource_group.tfstate.location
    account_tier              = "Standard"
    account_replication_type  = "LRS"
}

# Create the container for the state file
resource "azurerm_storage_container" "tfstate_container" {
    name                   = var.storage_container_name
    storage_account_name   = azurerm_storage_account.tfstate_storage.name
    container_access_type  = "private"
}

# Dynamically configure the backend storage
terraform {
    backend "azurerm" {
        resource_group_name   = azurerm_resource_group.tfstate.name
        storage_account_name  = azurerm_storage_account.tfstate_storage.name
        container_name        = azurerm_storage_container.tfstate_container.name
        key                   = "terraform.tfstate"
    }
}
