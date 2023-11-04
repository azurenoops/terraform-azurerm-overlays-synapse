# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_synapse_workspace_key" "workspace_key" {
  count = var.enable_customer_managed_keys == false ? 0 : 1

  customer_managed_key_versionless_id = azurerm_key_vault_key.key.0.versionless_id
  synapse_workspace_id                = azurerm_synapse_workspace.synapse.id
  active                              = true
  customer_managed_key_name           = "enckey"
  depends_on                          = [azurerm_key_vault_access_policy.workspace_policy]
}

resource "azurerm_key_vault_access_policy" "workspace_policy" {
  count = var.enable_customer_managed_keys == false ? 0 : 1

  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_synapse_workspace.synapse.identity[0].tenant_id
  object_id    = azurerm_synapse_workspace.synapse.identity[0].principal_id

  key_permissions = [
    "Get", "WrapKey", "UnwrapKey"
  ]
}

resource "azurerm_key_vault_access_policy" "deployer" {
  count = var.enable_customer_managed_keys == false ? 0 : 1

  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = var.object_id
  key_permissions = [
    "Create", "Get", "Delete", "Purge", "GetRotationPolicy"
  ]
}


resource "azurerm_key_vault_key" "key" {
  count = var.enable_customer_managed_keys == false ? 0 : 1

  name         = "workspaceencryptionkey"
  key_vault_id = var.key_vault_id
  key_type     = "RSA"
  key_size     = 2048
  key_opts = [
    "unwrapKey",
    "wrapKey"
  ]
  expiration_date = time_offset.pike.0.rfc3339
  depends_on      = [azurerm_key_vault_access_policy.deployer]
}

resource "time_offset" "pike" {
  count       = var.enable_customer_managed_keys == false ? 0 : 1
  offset_days = 7
}
