# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_synapse_sql_pool" "this" {
  name                 = var.name
  synapse_workspace_id = var.workspace_id
  sku_name             = var.sku_name
  create_mode          = var.create_mode
  collation            = var.create_mode == "Default" ? var.collation : null
  data_encrypted       = var.data_encrypted
  recovery_database_id = var.create_mode == "Recovery" ? var.recovery_database_id : null
  dynamic "restore" {
    for_each = coalesce([(var.create_mode == "PointInTimeRestore" ? var.restore : null)])
    content {
      source_database_id = restore.value.source_database_id
      point_in_time      = restore.value.point_in_time
    }
  }
  geo_backup_policy_enabled = var.geo_backup_policy_enabled

  tags = var.tags
}

#
# Auditing and alerting
#
data "azurerm_storage_account" "this" {
  name                = var.audit_storage_account_name
  resource_group_name = var.audit_storage_account_resource_group
}

resource "azurerm_storage_container" "this" {
  name                 = "${azurerm_synapse_sql_pool.this.name}_VaScans"
  storage_account_name = data.azurerm_storage_account.this.name
}

resource "azurerm_synapse_sql_pool_extended_auditing_policy" "this" {
  sql_pool_id                = azurerm_synapse_sql_pool.this.id
  storage_endpoint           = data.azurerm_storage_account.this.primary_blob_endpoint
  retention_in_days          = var.audit_retention_in_days
  storage_account_access_key = data.azurerm_storage_account.this.primary_access_key
  log_monitoring_enabled     = var.audit_log_monitoring_enabled
}

resource "azurerm_synapse_sql_pool_security_alert_policy" "this" {
  sql_pool_id                  = azurerm_synapse_sql_pool.this.id
  policy_state                 = var.alert_policy_state
  disabled_alerts              = var.disabled_alerts
  email_account_admins_enabled = var.alert_account_admins_email
  email_addresses              = var.alert_email_addresses
  retention_days               = var.alert_retention_days
  storage_account_access_key   = data.azurerm_storage_account.this.primary_access_key
  storage_endpoint             = data.azurerm_storage_account.this.primary_blob_endpoint
}

#
# Vulnerability Assesment
#
resource "azurerm_synapse_sql_pool_vulnerability_assessment" "this" {
  sql_pool_security_alert_policy_id = azurerm_synapse_sql_pool_security_alert_policy.this.id
  storage_container_path            = "${data.azurerm_storage_account.this.primary_blob_endpoint}${azurerm_storage_container.this.name}"
  storage_account_access_key        = data.azurerm_storage_account.this.primary_access_key
  recurring_scans {
    enabled                           = var.recurring_scans.enabled
    email_subscription_admins_enabled = var.recurring_scans.email_subcription_admins_enabled
    emails                            = var.recurring_scans.emails
  }
}

resource "azurerm_synapse_sql_pool_vulnerability_assessment_baseline" "this" {
  for_each = var.vulnerability_assessment_baselines

  name                                 = each.value.name
  rule_name                            = each.value.rule_id
  sql_pool_vulnerability_assessment_id = azurerm_synapse_sql_pool_vulnerability_assessment.this.id
  dynamic "baseline" {
    for_each = each.value.baselines

    content {
      result = baseline.result
    }
  }
}

#
# Workload groups
#
resource "azurerm_synapse_sql_pool_workload_group" "this" {
  for_each = var.workload_groups

  name                               = each.value.name
  sql_pool_id                        = azurerm_synapse_sql_pool.this.id
  max_resource_percent               = each.value.max_resource_percent
  min_resource_percent               = each.value.min_resource_percent
  importance                         = each.value.importance
  max_resource_percent_per_request   = each.value.max_resource_percent_per_request
  min_resource_percent_per_request   = each.value.min_resource_percent_per_request
  query_execution_timeout_in_seconds = each.value.query_execution_timeout_in_seconds
}

# We create a list of workload classifiers and their parents
# so that we easier can loop over them
locals {
  workload_classifiers = distinct(flatten([
    for group in var.workload_groups : [
      for classifier in group.workload_classifiers : {
        group_name = group.name
        classifier = classifier
      }
    ]
  ]))
}
resource "azurerm_synapse_sql_pool_workload_classifier" "this" {
  for_each = local.workload_classifiers

  name              = each.value.classifier.name
  workload_group_id = azurerm_synapse_sql_pool_workload_group.this["${each.value.group_name}"]
  member_name       = each.value.classifier.member_name
  context           = each.value.classifier.context
  end_time          = each.value.classifier.end_time
  importance        = each.value.classifier.importance
  label             = each.value.classifier.label
  start_time        = each.value.classifier.start_time
}