# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

locals {
  managed_resource_group_name = coalesce(var.managed_resource_group_name, data.azurenoopsutils_resource_name.rg.result)
  audit_storage = var.auditing_policy_storage_account_id == null ? {} : regex("resourceGroups/(?P<resource_group_name>.*?)/.*?/storageAccounts/(?P<storage_account_name>.*?)(?:$|/$)", var.auditing_policy_storage_account_id)

  synapse_library_requirements = format("%s/configuration_files/synapse_library_requirements.txt", path.root)
  synapse_spark_config         = format("%s/configuration_files/synapse_spark_config.txt", path.root)

}
