# backend-setup.tf (run this first separately)
provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "state_rg" {
    name     = "state-storage-rg"
    location = var.location
}

resource "azurerm_storage_account" "state_sa" {
    name                     = "statestorageaccount"
    resource_group_name      = azurerm_resource_group.state_rg.name
    location                 = azurerm_resource_group.state_rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_container" "state_container" {
    name                  = "tfstate"
    storage_account_name  = azurerm_storage_account.state_sa.name
    container_access_type = "private"
}
