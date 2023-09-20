
#Creating public ip required for nat gateway
resource "azurerm_public_ip" "nat-pubip" {
  name                = "nat-pubip"
  resource_group_name = azurerm_resource_group.demo-free5gc.name
  location            = azurerm_resource_group.demo-free5gc.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

#Creating my demo natgw for internet connectivity from VM
resource "azurerm_nat_gateway" "natGW-outbound" {
  name                = "natGW-outbound"
  resource_group_name = azurerm_resource_group.demo-free5gc.name
  location            = azurerm_resource_group.demo-free5gc.location
  sku_name            = "Standard"
  tags                = var.tags
}

#Assigning created public ip to NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat-pubip-assoc" {
  nat_gateway_id       = azurerm_nat_gateway.natGW-outbound.id
  public_ip_address_id = azurerm_public_ip.nat-pubip.id
}

#Assigning subnet01 to NatGW
resource "azurerm_subnet_nat_gateway_association" "nat-snet01-assoc" {
  subnet_id      = azurerm_subnet.demo-snet01.id
  nat_gateway_id = azurerm_nat_gateway.natGW-outbound.id
}

#Assigning subnet01 to NatGW
resource "azurerm_subnet_nat_gateway_association" "nat-snet02-assoc" {
  subnet_id      = azurerm_subnet.demo-snet02.id
  nat_gateway_id = azurerm_nat_gateway.natGW-outbound.id
}