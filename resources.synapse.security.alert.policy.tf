# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_synapse_workspace_security_alert_policy" "synapse_workspace_security_alert_policy" {
  count = var.sql_defender == null ? 0 : 1

  depends_on = [
    azurerm_role_assignment.audit_storage,
    data.azurerm_storage_account.audit_logs,
  ]

  synapse_workspace_id         = azurerm_synapse_workspace.synapse.id
  policy_state                 = var.sql_defender.state
  disabled_alerts              = var.sql_defender.disabled_alerts
  email_account_admins_enabled = var.sql_defender.email_account_admins_enabled
  email_addresses              = var.sql_defender.alert_email_addresses
  retention_days               = var.sql_defender.retention_days
  storage_endpoint             = data.azurerm_storage_account.audit_logs.0.primary_blob_endpoint
  storage_account_access_key   = data.azurerm_storage_account.audit_logs.0.primary_access_key
}