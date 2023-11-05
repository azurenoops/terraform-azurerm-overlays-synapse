# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#####################
### Compute Pools ###
#####################

resource "azurerm_synapse_spark_pool" "pool" {
  for_each = { for spark_pool in var.spark_pools : spark_pool.name => spark_pool }

  name                 = each.value.name
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  node_size_family     = each.value.node_size_family
  node_size            = each.value.node_size
  node_count           = each.value.auto_scale != null ? null : each.value.node_count
  auto_pause {
    delay_in_minutes = each.value.auto_pause_delay_in_minutes
  }

  dynamic "auto_scale" {
    for_each = each.value.auto_scale != null ? [each.value.auto_scale] : []
    content {
      max_node_count = auto_scale.value.max_node_count
      min_node_count = auto_scale.value.min_node_count
    }
  }
  cache_size                          = each.value.cache_size
  compute_isolation_enabled           = each.value.compute_isolation_enabled
  dynamic_executor_allocation_enabled = each.value.dynamic_executor_allocation_enabled
  min_executors                       = each.value.min_executors
  max_executors                       = each.value.max_executors
  dynamic "library_requirement" {
    for_each = each.value.library_requirement != null ? [each.value.library_requirement] : []
    content {
      content  = library_requirement.value.content
      filename = library_requirement.value.filename
    }
  }
  session_level_packages_enabled = each.value.session_level_packages_enabled
  dynamic "spark_config" {
    for_each = each.value.spark_config != null ? [each.value.spark_config] : []
    content {
      content  = spark_config.value.content
      filename = spark_config.value.filename
    }
  }
  spark_log_folder    = each.value.spark_log_folder
  spark_events_folder = each.value.spark_events_folder
  spark_version       = each.value.spark_version

  tags = merge(local.default_tags, var.add_tags, each.value.tags)
}