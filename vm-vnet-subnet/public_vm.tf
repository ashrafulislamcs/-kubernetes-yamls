resource "azurerm_public_ip" "ubuntu" {
  name                = "ubuntu0001publicip1"
  resource_group_name = var.azure_resource_group
  location            = var.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Stage"
  }
}

resource "azurerm_network_interface" "ubuntu" {
  name                = "ubuntu-terraform"
  location            = var.location
  resource_group_name = var.azure_resource_group

  ip_configuration {
    name                          = "public-nic"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = "192.168.0.20"
    public_ip_address_id          = azurerm_public_ip.ubuntu.id

  }
}


resource "azurerm_linux_virtual_machine" "ubuntu" {
  name                = "public-machine"
  resource_group_name = var.azure_resource_group
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  computer_name  = "public-machine"
  admin_password = "your_vm_password"
  disable_password_authentication="false"
  network_interface_ids = [
    azurerm_network_interface.ubuntu.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "19.04"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "ubuntu" {
  name                = "ubuntu-security-group1"
  location            = var.location
  resource_group_name = var.azure_resource_group

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Stage"
  }
}
resource "azurerm_network_interface_security_group_association" "ubuntu" {
    network_interface_id      = azurerm_network_interface.ubuntu.id
    network_security_group_id = azurerm_network_security_group.ubuntu.id
}



