# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id   = "3j3mpl0-D3-1d-suscr1pt10n"
  tenant_id         = "3j3mpl0-D3-1d-t3n4nt"
}
# Create a resource group
resource "azurerm_resource_group" "homework5" {
  name     = "homework5Endava"
  location = "West Europe"
  tags = {
    createdBy = "Javier Arevalo"
  }
}
# Create a virtual network within the resource group
resource "azurerm_virtual_network" "homework5" {
  name                = "homework5Endava-network"
  resource_group_name = azurerm_resource_group.homework5.name
  location            = azurerm_resource_group.homework5.location
  address_space       = ["192.168.0.0/24"]
  tags = {
    createdBy = "Javier Arevalo"
  }
}
# Create a subnet
resource "azurerm_subnet" "homework5" {
  name                 = "homework5Endava-subnet"
  resource_group_name  = azurerm_resource_group.homework5.name
  virtual_network_name = azurerm_virtual_network.homework5.name
  address_prefixes     = ["192.168.0.0/29"]
}
#Create a security group
resource "azurerm_network_security_group" "homework5" {
  name                = "homework5Endava-securityGroup"
  location            = azurerm_resource_group.homework5.location
  resource_group_name = azurerm_resource_group.homework5.name
  tags = {
    createdBy = "Javier Arevalo"
  }
}
#Create rules to security group
resource "azurerm_network_security_rule" "homework5" {
  for_each                    = local.nsgrules 
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.homework5.name
  network_security_group_name = azurerm_network_security_group.homework5.name
}
#Create public ip to virtual machine
resource "azurerm_public_ip" "homework5" {
  name                = "homework5Endava-publicip"
  resource_group_name = azurerm_resource_group.homework5.name
  location            = azurerm_resource_group.homework5.location
  allocation_method   = "Static"
  tags = {
    createdBy = "Javier Arevalo"
  }
}
#Create network interface to Virtual machine
resource "azurerm_network_interface" "homework5" {
  name                = "homework5Endava-nic"
  location            = azurerm_resource_group.homework5.location
  resource_group_name = azurerm_resource_group.homework5.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.homework5.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.homework5.id
  }
}
#Create association from security group to resources

resource "azurerm_subnet_network_security_group_association" "homework5" {
  subnet_id                 = azurerm_subnet.homework5.id
  network_security_group_id = azurerm_network_security_group.homework5.id
}
resource "azurerm_network_interface_security_group_association" "homework5" {
  network_interface_id      = azurerm_network_interface.homework5.id
  network_security_group_id = azurerm_network_security_group.homework5.id
}

#Create virtual machine
resource "azurerm_linux_virtual_machine" "homework5" {
  name                = "homework5Endava-machine"
  resource_group_name = azurerm_resource_group.homework5.name
  location            = azurerm_resource_group.homework5.location
  size                = "Standard_B1s"
  admin_username      = "endava"
  admin_password = "Homework5!"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.homework5.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "20.04.202209200"
  }
  tags = {
    createdBy = "Javier Arevalo"
  }
}

resource "azurerm_virtual_machine_extension" "homework5" {
    virtual_machine_id = azurerm_linux_virtual_machine.homework5.id
    name                    = "homework5Endava-machine-extension"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    protected_settings = <<PROT
    {
        "script": "${base64encode(file(var.commands))}"
    }
    PROT
}