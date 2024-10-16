output "resource_group_name" {
    value     = var.var.aks_cluster_name
    description = "The name of the resource group"
}

output "aks_cluster_name" {
    value       = var.aks_cluster_name
    description = "The name of the AKS cluster"
}
