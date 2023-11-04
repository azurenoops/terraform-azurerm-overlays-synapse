# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

############
# SQL Pool #
############

variable "name" {
  description = "The name of the SQL pool."
  type        = string
  default = null
}

variable "workspace_id" {
  description = "The id of the Synapse workspace this pool belongs to."
  type        = string
  default = null
}

variable "sku_name" {
  description = "The sku of this pool."
  type        = string

  default = "DW200c"
}

variable "create_mode" {
  description = "Specifies how to create the sql Pool. Valid values are: Default, Recovery or PointInTimeRestore"
  type        = string
  default     = "Default"
}

variable "collation" {
  description = "Specifies the collation of the SQL pool when create_mode is set to default"
  type        = string
  default     = "SQL_LATIN1_GENERAL_CP1_CI_AS"
}

variable "data_encrypted" {
  description = "Encrypt transperant data"
  type        = bool
  default     = true
}

variable "recovery_database_id" {
  description = "The ID of the Synapse SQL Pool or SQL Database which is to back up, only applicable when create_mode is set to Recovery."
  type        = string
  default     = null
}

variable "restore" {
  description = "A restore object. Only needed when create_mode is set to PointInTimeRestore."
  type = object({
    source_database_id : string
    point_in_time : string
  })
  default = null
}

variable "geo_backup_policy_enabled" {
  description = "Enable geo backup."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the sql pool."
  type        = map(string)
  default     = {}
}

##########################
# Auditing and alerting ##
##########################

variable "audit_storage_account_name" {
  description = "Name of the storage account to store audit logs in"
  type        = string
  default = null
}

variable "audit_storage_account_resource_group" {
  description = "Name of the resource group of the storage account to store audit logs in"
  type        = string
  default = null
}

variable "audit_retention_in_days" {
  description = "Amount of days to store audit logs"
  type        = number
  default     = 0
}

variable "audit_log_monitoring_enabled" {
  description = "Send logs to Azure Monitor"
  type        = bool
  default     = true
}

variable "alert_policy_state" {
  description = "Specifies the state of the policy, whether it is enabled or disabled or a policy has not been applied yet on the specific SQL pool. Possible values are Disabled, Enabled and New."
  type        = string
  default     = "Enabled"
}

variable "disabled_alerts" {
  description = "Specifies an array of alerts that are disabled. Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action."
  type        = list(string)
  default     = []
}

variable "alert_account_admins_email" {
  description = "Specifies if alerts should be sent to account administrators email."
  type        = bool
  default     = true
}

variable "alert_email_addresses" {
  description = "Specifies an array of email addresses to send alerts to."
  type        = list(string)
  default     = []
}

variable "alert_retention_days" {
  description = "Amount of days to store alert logs"
  type        = number
  default     = 0
}

############################
# Vulnerability Assesment  #
############################

variable "recurring_scans" {
  description = "A object defining recuring scans of the vulnerability assesment."
  type = list(object({
    enabled : optional(bool, true)
    email_subcription_admins_enabled : optional(bool, true)
    emails : optional(list(string), [])
  }))
  default = []
}

variable "vulnerability_assessment_baselines" {
  description = "List of vulnerability baselines. Look at https://learn.microsoft.com/en-us/azure/defender-for-cloud/sql-azure-vulnerability-assessment-rules for possible rules IDs."
  type = list(object({
    name : string
    rule_id : string
    baselines : optional(list(object({
      result : list(string)
    })), [])
  }))
  default = []
}

####################
# Workload groups ##
####################
variable "workload_groups" {
  description = "List of workload groups with their workload classifiers."
  type = list(object({
    name : string
    max_resource_percent : number
    min_resource_percent : number
    importance : optional(string, "normal")
    max_resource_percent_per_request : optional(number, null)
    min_resource_percent_per_request : optional(number, null)
    query_execution_timeout_in_seconds : optional(number, 60)
    workload_classifiers : optional(list(object({
      name : string
      member_name : string
      context : optional(string, null)
      end_time : optional(string, null)
      importance : optional(string, "normal")
      label : optional(string, null)
      start_time : optional(string, null)
    })), null)
  }))
  default = []
}