resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "stage-aks-cluster"
  location            = var.location
  resource_group_name = var.azure_resource_group
  dns_prefix          = "dns-k8s"

  default_node_pool {
    name                = "stage"
    node_count          = 1
    vm_size             = "Standard_B2s"
    os_disk_size_gb     = 40
    enable_auto_scaling = false
    vnet_subnet_id      = azurerm_subnet.subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "stage"
  }
}

resource "azurerm_role_assignment" "aks" {
    principal_id         = azurerm_kubernetes_cluster.cluster.identity[0].principal_id
    role_definition_name = "Network Contributor"
    scope                = azurerm_subnet.subnet.id
}
