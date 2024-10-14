provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "tfstate" {
    name     = "tfstate"
    location = var.location
}

# Generate a Random String to Ensure the Unique Storage Ackount Name 
resource "random_string" "resource_code" {
    length  = 5
    special = false
    upper   = false
}

# Create a Storage Account for Terraform State
resource "azurerm_storage_account" "tfstate" {
    name                     = "tfstate${random_string.resource_code.result}"
    resource_group_name      = azurerm_resource_group.tfstate.name
    location                 = azurerm_resource_group.tfstate.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
    allow_nested_items_to_be_public = false
    
    tags = {
        environment = "staging"
    }
}

# Backend Configuration
terraform {
    backend "azurerm" {
        resource_group_name   = "tfstate"
        # storage_account_name  = azurerm_storage_account.tfstate.name
        # container_name        = azurerm_storage_container.tfstate.name
        # key                   = "terraform.tfstate"  # Name of the state file
    }
}

# Create a Storage Container for State Files
resource "azurerm_storage_container" "tfstate" {
    name                  = "tfstate"
    storage_account_name  = azurerm_storage_account.tfstate.name
    container_access_type = "private"
}