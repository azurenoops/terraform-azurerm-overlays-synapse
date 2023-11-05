# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

############################
# Synapse Configuration  ##
############################

variable "saas_connection" {
  description = "Used to configure Public Network Access"
  type        = bool
  default     = false
}

variable "enable_managed_virtual_network" {
  description = "Is managed virtual network enabled in this workspace?"
  type        = bool
  default     = true
}

variable "compute_subnet_id" {
  description = "Subnet ID used for computes in workspace"
  type        = string
  default     = null
}

variable "data_exfiltration_protection_enabled" {
  description = "Is data exfiltration protection enabled in this workspace ?"
  type        = bool
  default     = false
}

variable "purview_id" {
  description = "The ID of purview account."
  type        = string
  default     = null
}


variable "managed_resource_group_name" {
  description = "Workspace managed resource group name"
  type        = string
  default     = null
}

variable "allowed_firewall_rules" {
  description = "List  of rules allowing certain ips through the firewall."
  type = list(object({
    name : string
    start_ip_address : string
    end_ip_address : string
  }))
  default = null
}

variable "managed_private_endpoints" {
  description = "List over managed private endpoints."
  type = list(object({
    name : string
    target_resource_id : string
    subresource_name : string
  }))
  default = []
}

#########################################
# Customer Managed Keys Configuration  ##
#########################################

variable "enable_customer_managed_keys" {
  description = "Enable customer managed keys for this workspace. Default is false."
  type        = bool
  default     = false
}

variable "key_vault_id" {
  description = "The ID of the key vault to be used for customer managed keys"
  type = string
  default = null
}

variable "tenant_id" {
  description = "The tenant ID of the key vault to be used for customer managed keys"
  type = string
  default = null
}

variable "object_id" {
  description = "The object ID of the key vault user principal id to be used for customer managed keys"
  type        = string  
  default = null
}

############################
# DataLake Configuration  ##
############################

variable "storage_data_lake_gen2_id" {
  description = "The ID of the storage account to be used for data lake gen2"
  type        = string
}

#######################
# SQL Configuration  ##
#######################

variable "sql_administrator_login" {
  description = "Administrator login of synapse sql database"
  type        = string
}

variable "sql_administrator_password" {
  description = "Administrator password of synapse sql database"
  type        = string
}

variable "sql_aad_admins" {
  description = "The SQL AAD admins of this workspace"
  type = set(object({
    login     = string
    object_id = string
    tenant_id = string
  }))

  default = []
}

variable "sql_identity_control_enabled" {
  description = "Are pipelines (running as workspace's system assigned identity) allowed to access SQL pools?"
  type        = bool
  default     = false
}

#######################
# AAD Configuration  ##
#######################

variable "aad_admins" {
  description = "The AAD admins of this workspace. Conflicts with customer_managed_key"
  type = list(object({
    login     = string
    object_id = string
    tenant_id = string
  }))

  default = []
}

variable "linking_allowed_for_aad_tenant_ids" {
  description = "Allowed Aad Tenant Ids For Linking"
  type        = list(string)
  default     = []
}

#########################
# Repo Configuration  ##
#########################

variable "azure_devops_configuration" {
  description = "Configuration for connecting the workspace to a Azure Devops repo."
  type = object({
    account_name    = string
    branch_name     = string
    last_commit_id  = optional(string)
    project_name    = string
    repository_name = string
    root_folder     = string
    tenant_id       = string
  })
  default = null
}

variable "github_repo" {
  description = "Configuration for connecting the workspace to a GitHub repo."
  type = object({
    account_name    = string
    branch_name     = string
    last_commit_id  = optional(string, null)
    repository_name = string
    root_folder     = optional(string, "/")
    git_url         = optional(string, null)
  })

  default = null
}

#####################################
# Synapse Identity Configuration   ##
#####################################

variable "identity_type" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account."
  type        = list(string)
  default     = null
}