
#########################
# Audit Configuration  ##
#########################

variable "enable_audit_log_monitoring" {
  description = "Enables or disabled audit log monitorng."
  type        = bool
  default     = true
}

variable "auditing_policy_storage_account_id" {
  description = "ID of SQL audit policy storage account"
  type        = string
  default     = null
}

variable "audit_retention_in_days" {
  description = "Number of days for retention of security policies"
  type        = number
  default     = 30
}

variable "sql_defender" {
  description = "Alert policy settings for the Synapse workspace. If null, no alert policy will be created. Audit_container is a blob storage container path to hold the scan results and all Threat Detection audit logs."
  type = object({
    state                        = optional(string, "Enabled")
    disabled_alerts              = optional(list(string), [])
    email_account_admins_enabled = optional(bool, false)
    alert_email_addresses        = optional(list(string), [])
    retention_days               = optional(number, 0)
    recurring_scans = optional(object({
      enabled                           = bool
      email_subscription_admins_enabled = bool
      emails                            = list(string)
    }))
    audit_container = optional(object({
      name                 = string
      storage_account_name = string
      resource_group_name  = string
    }))
  })

  default = null
}


