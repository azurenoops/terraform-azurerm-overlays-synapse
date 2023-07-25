# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "random_password" "synapse_sql_password" {
  count = signum(var.deploy_synapse ? 1 : 0)

  length           = 16
  special          = true
  override_special = "!#$*-_=+[]{}<>:?"
}


resource "azurerm_key_vault_secret" "synapse_sql_password" {
  count = signum(var.deploy_synapse ? 1 : 0)

  name         = format("%s%s", var.synapse_sql_admin_user, "-synapse-sql-admin")
  value        = random_password.synapse_sql_password.0.result
  key_vault_id = module.kv.id
}

resource "azurerm_synapse_workspace" "synapse" {
  count = signum(var.deploy_synapse ? 1 : 0)

  name                = format("%s%s", local.env_generic_map.resource_name_prefix, "synapse")
  resource_group_name = module.rg-ai.name
  location            = var.location

  storage_data_lake_gen2_filesystem_id = module.ai-datalake.filesystem_id

  sql_administrator_login          = var.synapse_sql_admin_user
  sql_administrator_login_password = random_password.synapse_sql_password.0.result

  managed_virtual_network_enabled = true
  public_network_access_enabled   = false

  managed_resource_group_name = format("%s-managed", module.rg-ai.name)

  customer_managed_key {
    key_versionless_id = module.ai-encryption-key-synapse.versionless_id
    key_name           = module.ai-encryption-key-synapse.name
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(local.default_tags, {})

  //https://learn.microsoft.com/en-us/cli/azure/synapse/workspace?view=azure-cli-latest#az-synapse-workspace-activate
  provisioner "local-exec" {
    command = format("az synapse workspace activate --name %s --workspace-name %s --resource-group %s --key-identifier %s",
      module.ai-encryption-key-synapse.name,
      format("%s%s", local.env_generic_map.resource_name_prefix, "synapse"),
    module.rg-ai.name, module.kv.vault_uri)
  }
}

//Give the Synapse Managed Identity access to the key vault
resource "azurerm_key_vault_access_policy" "synapse_access_policy" {
  count = signum(var.deploy_synapse ? 1 : 0)

  key_vault_id = module.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_synapse_workspace.synapse.0.identity[0].principal_id

  key_permissions    = ["Get", "UnwrapKey", "WrapKey"]
  secret_permissions = ["Get", "List"]
}

# resource "azurerm_synapse_workspace_aad_admin" "aad_admin" {
#   count = signum(var.deploy_synapse && length(var.synapse_aad_admin_user) > 0 ? 1 : 0 )

#   synapse_workspace_id = azurerm_synapse_workspace.synapse.0.id
#   login                = data.azuread_user.synapse_aad_admin.0.mail

#   object_id            = data.azuread_user.synapse_aad_admin.0.object_id
#   tenant_id            = data.azurerm_client_config.current.tenant_id
# }


