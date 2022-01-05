# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "stage-vnet"
  location            = var.location
  resource_group_name = var.azure_resource_group
  address_space       = ["192.168.0.0/16"]
}

# Create a Subnet for AKS
resource "azurerm_subnet" "subnet" {
  name                 = "stage-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.azure_resource_group
  address_prefixes     = ["192.168.0.0/24"]
}