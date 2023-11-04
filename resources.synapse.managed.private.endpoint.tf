# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_synapse_managed_private_endpoint" "this" {
  for_each = { for mpe in var.managed_private_endpoints : mpe.name => mpe }

  name                 = each.value.name
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  target_resource_id   = each.value.target_resource_id
  subresource_name     = each.value.subresource_name
}