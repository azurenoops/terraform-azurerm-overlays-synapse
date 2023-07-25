# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "create_cognitive_account" {
  description = "Create Cognitive Account"
  default     = false
}


variable "env_generic_map" {
  description = "Generic Environment Map for the Cognitive Account"
  type        = map(any)
  default     = {}
}

variable "sku" {
  dedescription = "SKU of the Cognitive Account"
  default       = "S0"
}

variable "kind" {
  description = "Kind of the Cognitive Account"
  default     = ""
}

variable "cmk_user_assigned_identity_id" {
  default     = null
  description = "User Managed Identity ID"
}

variable "cmk_key_vault_key_id" {
  default     = null
  description = "Key Vault Key ID"
}

variable "cmk_user_assigned_identity_client_id" {
  default     = null
  description = "User Managed Identity Client ID"
}
