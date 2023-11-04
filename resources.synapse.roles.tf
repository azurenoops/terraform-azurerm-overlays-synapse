# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/* resource "azurerm_synapse_role_assignment" "contributors" {
  for_each = toset(data.azuread_users.synapse_contributors.object_ids)

  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  role_name            = "Synapse Contributor"
  principal_id         = each.value
} */


# Add Contributor access for Synapse on the Audit account so it can write to it
resource "azurerm_role_assignment" "audit_storage" {
  count                = var.sql_defender == null ? 0 : 1
  scope                = data.azurerm_storage_account.audit_logs.0.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse.identity[0].principal_id
}
