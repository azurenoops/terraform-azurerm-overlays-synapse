# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_role_assignment" "synapse_sp_datalake" {
  count                = signum(var.deploy_synapse ? 1 : 0)
  scope                = module.ai-datalake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse.0.identity[0].principal_id
}