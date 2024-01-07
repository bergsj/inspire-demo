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
  name     = "${var.name}-rg-keyvault"
}

resource "azurerm_key_vault" "keyvault" {
  name                                   =  "${var.name}-kv-${random_string.platform-random-id-kv.result}"
  location                               =  var.resource_group_location
  resource_group_name                    =  azurerm_resource_group.rg-keyvault.name
  tenant_id                              =  data.azurerm_client_config.current.tenant_id
  sku_name                               =  "standard"
}

data "azurerm_client_config" "current" {}

resource "random_string" "platform-random-id-kv" {
  length                      = 5
  min_numeric                 = 2
  special                     = false
  upper                       = false
}




resource "random_string" "random-id" {
  length                      = 5
  min_numeric                 = 2
  special                     = false
  upper                       = false
}

resource "azurerm_resource_group" "rg-storage" {
  location = var.resource_group_location
  name     = "${var.name}-rg-storage"
}

resource "azurerm_storage_account" "sa" {
  account_replication_type               =  "LRS"
  account_tier                           =  "Standard"
  location                               =  var.resource_group_location
  min_tls_version                        =  "TLS1_0"
  name                                   =  "${var.name}sa${random_string.random-id.result}"
  resource_group_name                    =  azurerm_resource_group.rg-storage.name
}
