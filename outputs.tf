#Resource Group Name or Project Name
output "resource_group_name" {
  value       = azurerm_resource_group.demo-free5gc.name
  description = "This provides my resource group name or simply project name"
}

#Public IP Address of NATGW
output "natgw_public_ip_address" {
  // value       = azurerm_linux_virtual_machine.free5gc.
  value       = azurerm_public_ip.nat-pubip.ip_address
  description = "This provide public ip address of my nat gateway"
}

#Public IP Address of LB
output "lb_public_ip_address" {
  description = "Load Balancer Public Address"
  value       = azurerm_public_ip.lb-pubip.ip_address
}

# Load Balancer ID
output "lb_id" {
  description = "Load Balancer ID."
  value       = azurerm_lb.lb-inbound.id
}

# Load Balancer Frontend IP Configuration Block
output "lb_frontend_ip_configuration" {
  description = "LB frontend_ip_configuration Block"
  value       = [azurerm_lb.lb-inbound.frontend_ip_configuration]
}