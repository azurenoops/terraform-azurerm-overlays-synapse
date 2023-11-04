# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------
# Private Link for Data Factory - Default is "false" 
#---------------------------------------------------------
data "azurerm_virtual_network" "vnet" {
  count               = var.enable_private_endpoint && var.existing_virtual_network_name != null ? 1 : 0
  name                = var.existing_virtual_network_name
  resource_group_name = local.resource_group_name
}

data "azurerm_subnet" "snet" {
  count                = var.enable_private_endpoint && var.existing_private_subnet_name != null ? 1 : 0
  name                 = var.existing_private_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.0.name
  resource_group_name  = local.resource_group_name
}

resource "azurerm_private_endpoint" "pep_dev" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s-dev-private-endpoint", var.workload_name)
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = data.azurerm_subnet.snet.0.id
  tags                = merge({ "Name" = format("%s-private-dev-endpoint", var.workload_name) }, var.add_tags, )

  private_service_connection {
    name                           = "privatelink-dev-primary"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_synapse_workspace.synapse.id
    subresource_names              = ["Dev"]
  }
}

resource "azurerm_private_endpoint" "pep_sql" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s-sql-private-endpoint", var.workload_name)
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = data.azurerm_subnet.snet.0.id
  tags                = merge({ "Name" = format("%s-private-sql-endpoint", var.workload_name) }, var.add_tags, )

  private_service_connection {
    name                           = "privatelink-sql-primary"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_synapse_workspace.synapse.id
    subresource_names              = ["Sql"]
  }
}
