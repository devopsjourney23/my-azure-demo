#Creating public ip required for loadbalancer
resource "azurerm_public_ip" "lb-pubip" {
  name                = "lb-pubip"
  resource_group_name = azurerm_resource_group.demo-free5gc.name
  location            = azurerm_resource_group.demo-free5gc.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

#Creating my demo loadbalancer for connectivity to VM
resource "azurerm_lb" "lb-inbound" {
  name                = "lb-inbound"
  resource_group_name = azurerm_resource_group.demo-free5gc.name
  location            = azurerm_resource_group.demo-free5gc.location
  sku                 = "Standard"
  tags                = var.tags
  frontend_ip_configuration {
    name                 = "lb-pubip-01"
    public_ip_address_id = azurerm_public_ip.lb-pubip.id
  }
}

#Creating back end pool for lb
resource "azurerm_lb_backend_address_pool" "lb-be-pool" {
  name            = "lb-be-pool"
  loadbalancer_id = azurerm_lb.lb-inbound.id
}

#Creating loadbalancer probe to check status of backend pools
resource "azurerm_lb_probe" "lb-probe-ssh" {
  name            = "lb-probe-ssh"
  protocol        = "Tcp"
  port            = 22
  loadbalancer_id = azurerm_lb.lb-inbound.id
}

#Creating loadbalancer rule for ssh access
resource "azurerm_lb_rule" "lb-rule-ssh" {
  name                           = "lb-rule-ssh"
  loadbalancer_id                = azurerm_lb.lb-inbound.id
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = azurerm_lb.lb-inbound.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.lb-probe-ssh.id
  backend_address_pool_ids       = ["${azurerm_lb_backend_address_pool.lb-be-pool.id}"]
}

#Creating loadbalancer rule for webgui access
resource "azurerm_lb_rule" "lb-rule-webUI" {
  name                           = "lb-rule-webUI"
  loadbalancer_id                = azurerm_lb.lb-inbound.id
  protocol                       = "Tcp"
  frontend_port                  = 30500
  backend_port                   = 30500
  frontend_ip_configuration_name = azurerm_lb.lb-inbound.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.lb-probe-ssh.id
  backend_address_pool_ids       = ["${azurerm_lb_backend_address_pool.lb-be-pool.id}"]
}

#Adding nic01 to lb backend pool
resource "azurerm_network_interface_backend_address_pool_association" "lb-nic01-assoc" {
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-be-pool.id
  ip_configuration_name   = azurerm_network_interface.priv-nic01.ip_configuration[0].name
  network_interface_id    = azurerm_network_interface.priv-nic01.id
}

#Adding nic02 to lb backend pool
resource "azurerm_network_interface_backend_address_pool_association" "lb-nic02-assoc" {
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-be-pool.id
  ip_configuration_name   = azurerm_network_interface.priv-nic02.ip_configuration[0].name
  network_interface_id    = azurerm_network_interface.priv-nic02.id
}