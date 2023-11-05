# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


module "mod_synapse" {
  #source = "azurenoops/overlays-synapse/azurerm"  
  #version = "x.x.x"  
  source = "../../.."

  depends_on = [azurerm_resource_group.synapse_rg,
    azurerm_storage_account.logs,
    azurerm_storage_account.adls,
    azurerm_storage_container.sql_defender,
  azurerm_key_vault.kv]

  # By default, this module will create a resource group and 
  # provide a name for an existing resource group. If you wish 
  # to use an existing resource group, change the option 
  # to "create_synapse_resource_group = false." The location of the group 
  # will remain the same if you use the current resource.
  existing_resource_group_name = azurerm_resource_group.synapse_rg.name
  location                     = module.mod_azure_region_lookup.location_cli
  environment                  = var.environment
  deploy_environment           = var.deploy_environment
  org_name                     = var.org_name
  workload_name                = var.workload_name

  # The following variables are used to create a Datalake storage account
  storage_data_lake_gen2_id = azurerm_storage_account.adls.id

  # The following variables are used to create a SQL pool
  sql_administrator_login    = "Example"
  sql_administrator_password = var.sql_administrator_password

  # The following variables are used to create a workspace
  saas_connection                = false
  enable_managed_virtual_network = true

  # The following variables are used to create a private endpoint connection
  enable_private_endpoint       = true
  existing_virtual_network_name = azurerm_virtual_network.synapse_vnet.name
  existing_private_subnet_name  = azurerm_subnet.synapse_subnet.name

  # The following variables are used to create AAD Linked Tenants
  linking_allowed_for_aad_tenant_ids = []

  # The following variables are used to create a customer managed keys
  enable_customer_managed_keys = false
  //key_vault_id = azurerm_key_vault.kv.id
  //tenant_id = data.azurerm_client_config.current.tenant_id
  //object_id = data.azurerm_client_config.current.object_id

  # SQL Defender settings 
  auditing_policy_storage_account_id = azurerm_storage_account.logs.id
  audit_retention_in_days            = 30

  sql_defender = {
    retention_days = 30
    recurring_scans = {
      enabled                           = true
      email_subscription_admins_enabled = true
      emails                            = ["example@contoso.com"]
    }
    audit_container = {
      name                 = azurerm_storage_container.sql_defender.name
      storage_account_name = azurerm_storage_account.logs.name
      resource_group_name  = azurerm_resource_group.synapse_rg.name
    }
  }
}
