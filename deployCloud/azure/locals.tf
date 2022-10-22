locals { 
nsgrules = {
   
    ssh = {
      name                       = "AllowAnySSHInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 22
      source_address_prefix      = "129.151.110.163"
      destination_address_prefix = "192.168.0.0/29"
    }

    http = {
      name                       = "AllowAnyHTTPInbound"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = 80
      source_address_prefix      = "*"
      destination_address_prefix = "192.168.0.0/29"
    }
  }
 
}