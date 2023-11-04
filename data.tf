# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurerm_storage_account" "audit_logs" {
  count = var.sql_defender == null ? 0 : 1
  resource_group_name = local.audit_storage.resource_group_name
  name                = local.audit_storage.storage_account_name
}

data "azurerm_storage_container" "vulnerability_assessment" {
  count = var.sql_defender == null ? 0 : 1
  name                 = var.sql_defender.audit_container.name
  storage_account_name = var.sql_defender.audit_container.storage_account_name
}

data "azurerm_storage_account" "auditing_policy" {
  count = var.auditing_policy_storage_account_id == null ? 0 : 1
  name                = split("/", var.auditing_policy_storage_account_id)[8]
  resource_group_name = split("/", var.auditing_policy_storage_account_id)[4]
}