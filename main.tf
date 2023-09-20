#Creating storage account for boot diagnostic and access console
resource "azurerm_storage_account" "sa4bootdiag" {
  name                     = "sa4bootdiag"
  resource_group_name      = azurerm_resource_group.demo-free5gc.name
  location                 = azurerm_resource_group.demo-free5gc.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

#Creating my free5gc virtual machine on azure
resource "azurerm_linux_virtual_machine" "free5gc" {
  name                = "free5gc"
  resource_group_name = azurerm_resource_group.demo-free5gc.name
  location            = azurerm_resource_group.demo-free5gc.location
  size                = "Standard_F4"
  admin_username      = "lax"
  tags                = var.tags
  network_interface_ids = [
    azurerm_network_interface.priv-nic01.id,
    azurerm_network_interface.priv-nic02.id
  ]

  admin_ssh_key {
    username   = "lax"
    public_key = file("/home/lax/.ssh/id_rsa.pub")
    //public_key = file("C:\\Users\\laxmikant/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sa4bootdiag.primary_blob_endpoint
  }
}

#Creating null_resource for execution of readiness scripts
resource "null_resource" "pre_readiness_script" {
  connection {
    host        = azurerm_public_ip.lb-pubip.ip_address
    user        = "lax"
    type        = "ssh"
    private_key = file("/home/lax/.ssh/id_rsa")
    timeout     = "20m"
    agent       = false
  }

  provisioner "file" {
    source      = "readiness-script-01.sh"
    destination = "/home/lax/readiness-script-01.sh"
  }

  provisioner "file" {
    source      = "readiness-script-02.sh"
    destination = "/home/lax/readiness-script-02.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/lax/readiness-script-01.sh",
      "/home/lax/readiness-script-01.sh"
    ]
  }

  provisioner "local-exec" {
    command = "az vm restart -g demo-free5gc -n free5gc"
  }

  provisioner "local-exec" {
    command = "sleep 60"
    //command     = "start-sleep 60"
    //interpreter = ["PowerShell", "-Command"]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/lax/readiness-script-02.sh",
      "/home/lax/readiness-script-02.sh"
    ]
  }
  depends_on = [azurerm_linux_virtual_machine.free5gc]
}