# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_synapse_workspace_extended_auditing_policy" "synapse_auditing_policy" {
  count = var.auditing_policy_storage_account_id == null ? 0 : 1
  depends_on = [
    azurerm_role_assignment.audit_storage
  ]
  synapse_workspace_id                    = azurerm_synapse_workspace.synapse.id
  storage_endpoint                        = data.azurerm_storage_account.auditing_policy.0.primary_blob_endpoint
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.audit_retention_in_days
  log_monitoring_enabled                  = var.enable_audit_log_monitoring
}
