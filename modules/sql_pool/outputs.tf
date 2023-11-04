# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "sql_pool_id" {
  description = "The ID of this SQL Pool."
  value       = azurerm_synapse_sql_pool.this.id
}

output "auditing_policy_id" {
  description = "The ID of this auditing policy."
  value       = azurerm_synapse_sql_pool_extended_auditing_policy.this.id
}

output "alert_policy_id" {
  description = "The ID of this alert policy"
  value       = azurerm_synapse_sql_pool_security_alert_policy.this.id
}

output "vulnerability_assessment_id" {
  description = "The ID of this vulnerability assessment"
  value       = azurerm_synapse_sql_pool_vulnerability_assessment.this.id
}