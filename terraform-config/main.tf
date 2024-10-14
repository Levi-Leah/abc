resource "null_resource" "run_script" {
    provisioner "local-exec" {
        command = "bash ${path.module}/check_resources.sh ${var.resource_group_name}"
    }
    
    triggers = {
        always_run = "${timestamp()}"
    }
}

provider "azurerm" {
    features {}
}

# Create a Resource Group to hold your resources (network, cluster, etc.)
resource "azurerm_resource_group" "aks_rg" {
    name     = var.resource_group_name  # Reference the variable for the resource group name
    location = var.location             # Reference the variable for location
}

# Create a Virtual Network in the resource group
resource "azurerm_virtual_network" "aks_vnet" {
    name                = var.vnet_name                # Name of the virtual network
    address_space       = var.address_space            # IP range for the virtual network
    location            = azurerm_resource_group.aks_rg.location  # Use the same location as the resource group
    resource_group_name = azurerm_resource_group.aks_rg.name       # Assign to the created resource group
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "aks_subnet" {
    name                 = var.subnet_name               # Name of the subnet
    resource_group_name  = azurerm_resource_group.aks_rg.name  # Assign to the resource group
    virtual_network_name = azurerm_virtual_network.aks_vnet.name  # Link to the virtual network
    address_prefixes     = var.subnet_address_prefixes   # IP range for the subnet
}

# Create the Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
    name                = var.aks_cluster_name   # Reference the variable for the AKS cluster name
    location            = var.location           # Use the same location as the resource group
    resource_group_name = azurerm_resource_group.aks_rg.name  # Assign to the resource group
    dns_prefix          = var.dns_prefix         # Prefix for DNS names in the cluster
    
    default_node_pool {
        name       = "default"                     # Name of the node pool
        node_count = var.node_count                # Number of nodes in the pool
        vm_size    = var.vm_size                   # Size of the virtual machines (nodes)
        vnet_subnet_id = azurerm_subnet.aks_subnet.id  # Link to the created subnet
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

# Output the Kubernetes config file (kubeconfig), needed to manage the cluster
output "kube_config" {
    value     = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
    sensitive = true  # Mark this as sensitive because it contains credentials
}
