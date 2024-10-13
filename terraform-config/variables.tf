# Location for deploying resources
variable "location" {
    description = "Azure region to deploy resources"
    default     = "Japan West"
}

# Resource group name
variable "resource_group_name" {
    description = "The name of the resource group"
    default     = "AKSResourceGroup"
}

# Virtual network name
variable "vnet_name" {
    description = "The name of the virtual network"
    default     = "AKS-vnet"
}

# Address space for the virtual network
variable "address_space" {
    description = "IP address space for the virtual network"
    default     = ["10.0.0.0/16"]
}

# Subnet name
variable "subnet_name" {
    description = "The name of the subnet"
    default     = "-subnet"
}

# Address prefix for the subnet
variable "subnet_address_prefixes" {
    description = "IP address prefixes for the subnet"
    default     = ["10.0.0.0/24"]
}

# AKS cluster name
variable "aks_cluster_name" {
    description = "The name of the AKS cluster"
    default     = "AKSCluster"
}

# DNS prefix for AKS
variable "dns_prefix" {
    description = "Prefix for DNS names in the AKS cluster"
    default     = "AKSClust-AKSResourceGroup"
}

# Node count for the cluster
variable "node_count" {
    description = "Number of nodes in the AKS cluster"
    default     = 1
}

# VM size for AKS nodes
variable "vm_size" {
    description = "VM size for the AKS cluster nodes"
    default     = "Standard_DS2_v2"
}

# IP CIDR to avoid ServiceCidrOverlapExistingSubnetsCidr Error
variable "service_cidr" {
    description = "IP address for the service CIDR"
    default = "10.30.0.0/16"
}