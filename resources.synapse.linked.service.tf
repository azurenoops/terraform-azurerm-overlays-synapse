# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_synapse_linked_service" "this" {
  for_each = { for ls in var.linked_services : ls.name => ls }

  name                  = each.value.name
  synapse_workspace_id  = azurerm_synapse_workspace.synapse.id
  type                  = each.value.type
  type_properties_json  = jsonencode(each.value.type_properties)
  additional_properties = each.value.additional_properties
  annotations           = each.value.annotations
  description           = each.value.description
  dynamic "integration_runtime" {
    for_each = each.value.integration_runtime != null ? [each.value.integration_runtime] : []
    content {
      name       = integration_runtime.value.name
      parameters = integration_runtime.value.parameters
    }
  }
  parameters = each.value.parameters
}