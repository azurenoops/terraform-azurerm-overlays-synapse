# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#################
### SQL Pools ###
#################

resource "azurerm_synapse_sql_pool" "sql_pool" {
  for_each = { for sql_pool in var.sql_pools : sql_pool.name => sql_pool }

  name                 = each.value.name
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  sku_name             = each.value.sku_name
  create_mode          = each.value.create_mode
  collation            = each.value.create_mode == "Default" ? each.value.collation : null
  data_encrypted       = each.value.data_encrypted
  recovery_database_id = each.value.create_mode == "Recovery" ? each.value.recovery_database_id : null

  dynamic "restore" {
    for_each = each.value.create_mode == "PointInTimeRestore" ? [each.value.restore] : []
    content {
      source_database_id = restore.value.source_database_id
      point_in_time      = restore.value.point_in_time
    }
  }
  
  geo_backup_policy_enabled = each.value.geo_backup_policy_enabled

  tags = merge(local.default_tags, var.add_tags, each.value.tags)
}
