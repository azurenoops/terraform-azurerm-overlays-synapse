# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_synapse_workspace" "synapse" {
  name                = local.name
  resource_group_name = local.resource_group_name
  location            = local.location

  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.datalake.id

  sql_administrator_login          = var.sql_administrator_login
  sql_administrator_login_password = var.sql_administrator_password == null ? random_password.synapse_sql_password.0.result : var.sql_administrator_password

  public_network_access_enabled        = var.saas_connection
  managed_virtual_network_enabled      = var.enable_managed_virtual_network
  linking_allowed_for_aad_tenant_ids   = var.linking_allowed_for_aad_tenant_ids
  compute_subnet_id                    = var.compute_subnet_id
  data_exfiltration_protection_enabled = var.data_exfiltration_protection_enabled
  purview_id                           = var.purview_id
  sql_identity_control_enabled         = var.sql_identity_control_enabled
  managed_resource_group_name          = local.managed_resource_group_name

  dynamic "sql_aad_admin" {
    for_each = { for sql_aad_admin in var.sql_aad_admins : sql_aad_admin.login => sql_aad_admin }

    content {
      login     = sql_aad_admin.value.login
      object_id = sql_aad_admin.value.object_id
      tenant_id = sql_aad_admin.value.tenant_id
    }
  }
  dynamic "aad_admin" {
    for_each = { for aad_admin in var.aad_admins : aad_admin.login => aad_admin }

    content {
      login     = aad_admin.value.login
      object_id = aad_admin.value.object_id
      tenant_id = aad_admin.value.tenant_id
    }
  }

  dynamic "azure_devops_repo" {
    for_each = toset(var.azure_devops_configuration == null ? [] : [var.azure_devops_configuration])
    content {
      account_name    = azure_devops_repo.value.account_name
      branch_name     = azure_devops_repo.value.branch_name
      last_commit_id  = try(azure_devops_repo.value.last_commit_id, null)
      project_name    = azure_devops_repo.value.project_name
      repository_name = azure_devops_repo.value.repository_name
      root_folder     = azure_devops_repo.value.root_folder
      tenant_id       = azure_devops_repo.value.tenant_id
    }
  }

  dynamic "github_repo" {
    for_each = var.github_repo == null ? [] : [var.github_repo]
    content {
      account_name    = github_repo.value.account_name
      branch_name     = github_repo.value.branch_name
      last_commit_id  = lookup(github_repo.value, "last_commit_id", null)
      repository_name = github_repo.value.repository_name
      root_folder     = lookup(github_repo.value, "root_folder", "/")
      git_url         = lookup(github_repo.value, "git_url", null)
    }
  }

  dynamic "identity" {
    for_each = var.identity_type == null ? [] : ["enabled"]
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids == "UserAssigned" ? var.identity_ids : null
    }
  }

  dynamic "customer_managed_key" {
    for_each = toset(var.enable_customer_managed_keys == false ? [] : [1])
    content {
      key_versionless_id = azurerm_key_vault_key.key.0.versionless_id
      key_name           = "encKey"
    }
  }

  tags = merge(local.default_tags, var.add_tags)

  lifecycle {
    ignore_changes = [github_repo[0].last_commit_id, azure_devops_repo[0].last_commit_id]
  }
}

resource "random_password" "synapse_sql_password" {
  count = var.sql_administrator_password == null ? 1 : 0

  length           = 16
  special          = true
  override_special = "!#$*-_=+[]{}<>:?"
}
