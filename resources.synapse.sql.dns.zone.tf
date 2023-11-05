# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#----------------------------------------------------------------------------
# DNS zone & records for Synapse SQL Private endpoints - Default is "false" 
#----------------------------------------------------------------------------
data "azurerm_private_endpoint_connection" "pip_sql" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep_sql.0.name
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_synapse_workspace.synapse]
}

resource "azurerm_private_dns_zone" "sql_dns_zone" {
  count               = var.existing_sql_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = var.environment == "public" ? "privatelink.sql.azuresynapse.net" : "privatelink.sql.azuresynapse.usgovcloudapi.net"
  resource_group_name = local.resource_group_name
  tags                = merge({ "Name" = format("%s", "Azure-Private-DNS-Zone") }, var.add_tags, )
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_vnet_link" {
  count                 = var.existing_sql_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                  = "vnet-private-zone-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns_zone.0.name
  virtual_network_id    = data.azurerm_virtual_network.vnet.0.id
  registration_enabled  = false
  tags                  = merge({ "Name" = format("%s", "vnet-private-zone-link") }, var.add_tags, )
}

resource "azurerm_private_dns_a_record" "a_rec_sql" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_synapse_workspace.synapse.name
  zone_name           = var.existing_sql_private_dns_zone == null ? azurerm_private_dns_zone.sql_dns_zone.0.name : var.existing_sql_private_dns_zone
  resource_group_name = local.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.pip_sql.0.private_service_connection.0.private_ip_address]
}
