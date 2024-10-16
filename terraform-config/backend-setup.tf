# If value names change, they must be manually updated in .github/workflows/github-actions.yml

# Define the resource group for Terraform state storage
resource "azurerm_resource_group" "tfstate" {
    name     = "XYZStorageResourceGroup"
    location = var.location
}

# Create the storage account for the state file
resource "azurerm_storage_account" "tfstate_storage" {
    name                      = "xyzstorageaccountunique1"
    resource_group_name       = azurerm_resource_group.tfstate.name
    location                  = azurerm_resource_group.tfstate.location
    account_tier              = "Standard"
    account_replication_type  = "LRS"
}

# Create the container for the state file
resource "azurerm_storage_container" "tfstate_container" {
    name                   = "xyztoragecontainer"
    storage_account_name   = azurerm_storage_account.tfstate_storage.name
    container_access_type  = "private"
}

# Configure the backend storage
terraform {
    backend "azurerm" {
        resource_group_name   = "XYZStorageResourceGroup"
        storage_account_name  = "xyzstorageaccountunique1"
        container_name        = "xyztoragecontainer"
        key                   = "terraform.tfstate"
    }
}
