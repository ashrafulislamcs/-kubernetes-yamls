resource "azurerm_public_ip" "windows" {
  name                = "windows0001publicip1"
  resource_group_name = var.azure_resource_group
  location            = var.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Stage"
  }
}

resource "azurerm_network_interface" "windows" {
  name                = "windows-terraform"
  location            = var.location
  resource_group_name = var.azure_resource_group

  ip_configuration {
    name                          = "public-nic"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = "192.168.0.21"
    public_ip_address_id          = azurerm_public_ip.windows.id

  }
}


resource "azurerm_windows_virtual_machine" "windows" {
  name                = "public-machine"
  resource_group_name = var.azure_resource_group
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "your-username"
  computer_name  = "public-machine"
  admin_password = "your-password"
  network_interface_ids = [
    azurerm_network_interface.windows.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
