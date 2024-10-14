#!/bin/bash

# Pass the Azure Subscription ID from GitHub
AZURE_SUBSCRIPTION_ID=$1

# Parse the the resource group name from Terraform
eval "$(jq -r '@sh "RESOURCE_GROUP=\(.resource_group_name)"')"

# Check if the resource group exists
rg_exists=$(az group exists --name "$RESOURCE_GROUP")

if [[ "$rg_exists" == "true" ]]; then
    echo "Resource group $RESOURCE_GROUP already exists. Importing all resources into Terraform..."

    # Import the resource group
    terraform import azurerm_resource_group.aks_rg /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP

    # Import virtual network
    terraform import azurerm_virtual_network.aks_vnet /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/virtualNetworks/$VNET_NAME

    # Import subnet
    terraform import azurerm_subnet.aks_subnet /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/virtualNetworks/$VNET_NAME/subnets/$SUBNET_NAME

    # Import AKS cluster
    terraform import azurerm_kubernetes_cluster.aks_cluster /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ContainerService/managedClusters/$AKS_CLUSTER_NAME
else
    echo "Resource group $RESOURCE_GROUP does not exist. Terraform will create it and all associated resources."
fi

# Return JSON to Terraform
jq -n --arg result "done" '{"result": $result}'
