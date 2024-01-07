resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${var.name}-rg"
}

resource "azurerm_windows_virtual_machine" "main" {
  name                  = "${var.name}-vm"

  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name

  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.size

  os_disk {
    name                 = "${var.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  admin_username        = "demoadmin"
  admin_password        = random_password.password.result

  boot_diagnostics {
  }
}

resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}


resource "azurerm_resource_group" "rg-keyvault" {
  location = var.resource_group_location
  name     = "${var.name}-rg"
}

resource "azurerm_key_vault" "keyvault" {
  name                                   =  "${var.name}-kv-${random_id.keyvault_name.hex}"
  location                               =  var.resource_group_location
  resource_group_name                    =  azurerm_resource_group.rg-keyvault.name
  tenant_id                              =  data.azurerm_client_config.current.tenant_id
  sku_name                               =  "Standard"
}

data "azurerm_client_config" "current" {}

resource "random_id" "keyvault_name" {
  byte_length                            =  5
  prefix                                 =  "keyvault"
}