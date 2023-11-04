# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurerm_client_config" "current" {}

module "mod_azure_region_lookup" {
  source  = "azurenoops/overlays-azregions-lookup/azurerm"
  version = "~> 1.0.0"

  azure_region = var.location
}

resource "azurerm_resource_group" "synapse_rg" {
  name     = "rg-synapse"
  location = module.mod_azure_region_lookup.location_cli
}

resource "azurerm_virtual_network" "synapse_vnet" {
  name                = "vnet-synapse"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.synapse_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "synapse_subnet" {
  name                 = "snet-synapse"
  resource_group_name  = azurerm_resource_group.synapse_rg.name
  virtual_network_name = azurerm_virtual_network.synapse_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  private_endpoint_network_policies_enabled = false
  private_link_service_network_policies_enabled = true
}

resource "azurerm_storage_account" "logs" {
  name = "stsynapselogs"

  resource_group_name      = azurerm_resource_group.synapse_rg.name
  location                 = module.mod_azure_region_lookup.location_cli
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

resource "azurerm_storage_account" "adls" {
  name = "stsynapzb34"

  resource_group_name      = azurerm_resource_group.synapse_rg.name
  location                 = module.mod_azure_region_lookup.location_cli
  is_hns_enabled           = true
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

resource "azurerm_storage_container" "sql_defender" {
  name                  = "synapse-sql-defender"
  storage_account_name  = azurerm_storage_account.logs.name
  container_access_type = "private"
}

