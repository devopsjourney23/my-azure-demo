variable "resource_group_location" {
  default     = "australiaeast"
  description = "Location of the resource group"
}

variable "resource_group_name" {
  default     = "demo-free5gc"
  description = "Resource Group Name in My Azure Subscription"
}

variable "resource_vnet_address" {
  default     = "172.168.0.0/16"
  description = "IP Address range used for Virtual Network Resource Group "
}

variable "resource_snet01_address" {
  default     = "172.168.0.0/24"
  description = "IP Address range used for first Subnet Resource Group"
}

variable "resource_snet02_address" {
  default     = "172.168.1.0/24"
  description = "IP Address range used for second Subnet Resource Group"
}

variable "tags" {
  default = {
    environment = "demo"
  }
  description = "Add demo project tag to resources"
}