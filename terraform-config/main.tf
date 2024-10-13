provider "azurerm" {
    features {}
}

##################################################
# CHECK IF RESOURCES ALREADY EXIST
##################################################

# Check if the Resource Group already exists
data "azurerm_resource_group" "existing_rg" {
    name = var.resource_group_name
    count = try(length(data.azurerm_resource_group.existing_rg[count.index].name), 0) != 0 ? 0 : 1
}

# Check if the Virtual Network already exists
data "azurerm_virtual_network" "existing_vnet" {
    name                = var.vnet_name
    resource_group_name = var.resource_group_name
    count = try(length(data.azurerm_virtual_network.existing_vnet[count.index].name), 0) != 0 ? 0 : 1
}

# Check if the Subnet already exists
data "azurerm_subnet" "existing_subnet" {
    name                = var.subnet_name
    resource_group_name = var.resource_group_name
    virtual_network_name = var.vnet_name
    count = try(length(data.azurerm_subnet.existing_subnet[count.index].name), 0) != 0 ? 0 : 1
}

# Check if the AKS Cluster already exists
data "azurerm_kubernetes_cluster" "existing_aks" {
    name                = var.aks_cluster_name
    resource_group_name = var.resource_group_name
    count = try(length(data.azurerm_kubernetes_cluster.existing_aks[count.index].name), 0) != 0 ? 0 : 1
}

##################################################
# CREATE RESOURCES IF THEY DO NOT EXIST
##################################################


# Create a Resource Group to hold your resources (network, cluster, etc.)
resource "azurerm_resource_group" "aks_rg" {
    count    = length(data.azurerm_resource_group.existing_rg.name) != 0 ? 0 : 1
    name     = var.resource_group_name
    location = var.location
}

# Create a Virtual Network in the resource group
resource "azurerm_virtual_network" "aks_vnet" {
    count               = length(data.azurerm_virtual_network.existing_vnet.name) != 0 ? 0 : 1
    name                = var.vnet_name
    address_space       = var.address_space
    location            = azurerm_resource_group.aks_rg[count.index].location # list of resources rather than a single instance and must be refer to it using an index
    resource_group_name = azurerm_resource_group.aks_rg[count.index].name
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "aks_subnet" {
    count               = length(data.azurerm_subnet.existing_subnet.name) != 0 ? 0 : 1
    name                 = var.subnet_name 
    resource_group_name  = azurerm_resource_group.aks_rg[count.index].name
    virtual_network_name = azurerm_virtual_network.aks_vnet[count.index].name
    address_prefixes     = var.subnet_address_prefixes
}

# Create the Azure Kubernetes Service AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
    count               = length(data.azurerm_kubernetes_cluster.existing_aks.name) != 0 ? 0 : 1
    name                = var.aks_cluster_name
    location            = var.location
    resource_group_name = azurerm_resource_group.aks_rg[count.index].name
    dns_prefix          = var.dns_prefix
    
    default_node_pool {
        name       = "default"                     # Name of the node pool
        node_count = var.node_count                # Number of nodes in the pool
        vm_size    = var.vm_size                   # Size of the virtual machines (nodes)
        vnet_subnet_id = azurerm_subnet.aks_subnet[count.index].id  # Link to the created subnet
    }

    # Set network profile to avoid the ServiceCidrOverlapExistingSubnetsCidr Error
    network_profile {
        network_plugin     = "azure"
        service_cidr       = var.service_cidr
        dns_service_ip     = var.dns_service_ip
    }
    
    # Managed identity for AKS (Azure handles the identity for the cluster)
    identity {
        type = "SystemAssigned"
        }
}

# Output the Kubernetes kubeconfig to manage the cluster
output "kube_config" {
    value     = length(azurerm_kubernetes_cluster.aks_cluster) > 0 ? azurerm_kubernetes_cluster.aks_cluster[0].kube_config_raw : "" #  Output the kube_config only if the AKS cluster was created
    sensitive = true  # Mark this as sensitive because it contains credentials
}