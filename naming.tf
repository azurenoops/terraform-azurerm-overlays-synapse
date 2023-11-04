# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------
# Azure NoOps Naming - This should be used on all resource naming
# https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs
#------------------------------------------------------------
data "azurenoopsutils_resource_name" "synapse" {
  name          = var.workload_name
  resource_type = "azurerm_synapse_workspace"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azure_region_lookup.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "synapse"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "rg" {
  name          = var.workload_name
  resource_type = "azurerm_resource_group"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azure_region_lookup.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "synapse"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}
