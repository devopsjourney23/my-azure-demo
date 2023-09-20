#Creating my demo-free5gc resource group
resource "azurerm_resource_group" "demo-free5gc" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

#Creating my demo Virtual Network ip segment
resource "azurerm_virtual_network" "demo-vnet" {
  name                = "demo-vnet"
  address_space       = [var.resource_vnet_address]
  location            = azurerm_resource_group.demo-free5gc.location
  resource_group_name = azurerm_resource_group.demo-free5gc.name
}

#Creating my first SubNet from virtual network
resource "azurerm_subnet" "demo-snet01" {
  name                 = "demo-snet01"
  resource_group_name  = azurerm_resource_group.demo-free5gc.name
  virtual_network_name = azurerm_virtual_network.demo-vnet.name
  address_prefixes     = [var.resource_snet01_address]
}

#Creating my second SubNet from virtual network
resource "azurerm_subnet" "demo-snet02" {
  name                 = "demo-snet02"
  resource_group_name  = azurerm_resource_group.demo-free5gc.name
  virtual_network_name = azurerm_virtual_network.demo-vnet.name
  address_prefixes     = [var.resource_snet02_address]
}

#Creating my first private nic
resource "azurerm_network_interface" "priv-nic01" {
  name                 = "priv-nic01"
  location             = azurerm_resource_group.demo-free5gc.location
  resource_group_name  = azurerm_resource_group.demo-free5gc.name
  enable_ip_forwarding = true
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.demo-snet01.id
    private_ip_address_allocation = "Dynamic"
    //public_ip_address_id          = azurerm_public_ip.<publicaddress-id>
  }
}

#Creating my second private nic
resource "azurerm_network_interface" "priv-nic02" {
  name                 = "priv-nic02"
  location             = azurerm_resource_group.demo-free5gc.location
  resource_group_name  = azurerm_resource_group.demo-free5gc.name
  enable_ip_forwarding = true
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.demo-snet02.id
    private_ip_address_allocation = "Dynamic"
    //public_ip_address_id          = azurerm_public_ip.<publicaddress-id>
  }
}

#Creating my demo Network Security Group and allowing ssh access
resource "azurerm_network_security_group" "nsg-allow-all-trafffic" {
  name                = "demnsg-allow-all-traffficoNSG"
  location            = azurerm_resource_group.demo-free5gc.location
  resource_group_name = azurerm_resource_group.demo-free5gc.name

  /*  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WebUI"
    priority                   = 1101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
*/
  security_rule {
    name                       = "All-inbound"
    priority                   = 1201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "0-65535"
    destination_port_range     = "0-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "All-output"
    priority                   = 1301
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "0-65535"
    destination_port_range     = "0-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Assigning created network security group to subnets
resource "azurerm_subnet_network_security_group_association" "snet01-nsg-assoc" {
  subnet_id                 = azurerm_subnet.demo-snet01.id
  network_security_group_id = azurerm_network_security_group.nsg-allow-all-trafffic.id
}

#Assigning created network security group to subnets
resource "azurerm_subnet_network_security_group_association" "snet02-nsg-assoc" {
  subnet_id                 = azurerm_subnet.demo-snet02.id
  network_security_group_id = azurerm_network_security_group.nsg-allow-all-trafffic.id
}