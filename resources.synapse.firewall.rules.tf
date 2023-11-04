# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_synapse_firewall_rule" "rules" {
  for_each = toset(var.allowed_firewall_rules == null ? [] : { for fr in var.allowed_firewall_rules : fr.name => fr })

  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  name                 = each.value.name
  start_ip_address     = each.value.start_ip_address
  end_ip_address       = each.value.end_ip_address
}