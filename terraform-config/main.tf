provider "azurerm" {
    features {}
}

resource "null_resource" "run_script" {
    provisioner "local-exec" {
        command = "bash ${path.module}/check_resources.sh ${var.resource_group_name}"
    }
    
    triggers = {
        always_run = "${timestamp()}"
    }
}

# Create a Resource Group
resource "azurerm_resource_group" "aks_rg" {
    name     = var.resource_group_name
    location = var.location
}

# Create a Virtual Network in the resource group
resource "azurerm_virtual_network" "aks_vnet" {
    name                = var.vnet_name
    address_space       = var.address_space
    location            = azurerm_resource_group.aks_rg.location
    resource_group_name = azurerm_resource_group.aks_rg.name
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "aks_subnet" {
    name                 = var.subnet_name
    resource_group_name  = azurerm_resource_group.aks_rg.name
    virtual_network_name = azurerm_virtual_network.aks_vnet.name
    address_prefixes     = var.subnet_address_prefixes
}

# Create the Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
    name                = var.aks_cluster_name
    location            = var.location
    resource_group_name = azurerm_resource_group.aks_rg.name
    dns_prefix          = var.dns_prefix
    
    default_node_pool {
        name       = "default"
        node_count = var.node_count
        vm_size    = var.vm_size
        vnet_subnet_id = azurerm_subnet.aks_subnet.id 
    }

    # Set network profile to avoid the ServiceCidrOverlapExistingSubnetsCidr Error
    network_profile {
        network_plugin     = "azure"
        service_cidr       = var.service_cidr
        dns_service_ip     = var.dns_service_ip
    }
    
    # Managed identity for AKS
    identity {
        type = "SystemAssigned"
        }
}

# Define the resource to generate kubeconfig using Azure CLI
resource "null_resource" "get_kubeconfig" {
    depends_on = [
        azurerm_resource_group.aks_rg,
        azurerm_virtual_network.aks_vnet,
        azurerm_subnet.aks_subnet,
        azurerm_kubernetes_cluster.aks_cluster
    ]

    provisioner "local-exec" {
        command = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${var.aks_cluster_name} --file ${path.module}/kubeconfig --overwrite-existing"
    }
}

# # Verify cluster connectivity using kubectl
# resource "null_resource" "verify_cluster" {
#     provisioner "local-exec" {
#         command = "kubectl --kubeconfig=${path.module}/kubeconfig get nodes"
#     }
# }

# Define the Helm release
resource "helm_release" "nodejs_app" {
    depends_on = [null_resource.get_kubeconfig]  # Wait until kubeconfig is generated
    name       = "abc"
    chart      = "../helm-config"
    namespace  = "default"
}