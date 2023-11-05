# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#######################################
# Synapse SQL Pools Configuration    ##
#######################################

variable "sql_pools" {
  description = "A list of sql pools to create."
  type = list(object({
    name : string
    sku_name : string
    create_mode : optional(string, "Default")
    collation : optional(string, "SQL_LATIN1_GENERAL_CP1_CI_AS")
    data_encrypted : optional(string, true)
    recovery_database_id : optional(string, null)
    restore : optional(object({
      source_database_id : optional(string)
      point_in_time : optional(string)
    }), null)
    geo_backup_policy_enabled : optional(bool, true)
    tags : optional(map(string), null)
  }))
  default = []
}
