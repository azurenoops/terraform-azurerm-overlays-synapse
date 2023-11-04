# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


###########################
# Global Configuration   ##
###########################

variable "location" {
  description = "Azure region in which instance will be hosted"
  type        = string
}

variable "environment" {
  description = "The Terraform backend environment e.g. public or usgovernment"
  type        = string
}

variable "deploy_environment" {
  description = "Name of the workload's environment"
  type        = string
}

variable "workload_name" {
  description = "Name of the workload_name"
  type        = string
}

variable "org_name" {
  description = "Name of the organization"
  type        = string
}

#######################
# RG Configuration   ##
#######################

variable "create_synapse_resource_group" {
  description = "Create a resource group for the Synapse Workspace. If set to false, the existing_resource_group_name variable must be set. Default is false."
  type        = bool
  default     = false
}

variable "use_location_short_name" {
  description = "Use short location name for resources naming (ie eastus -> eus). Default is true. If set to false, the full cli location name will be used. if custom naming is set, this variable will be ignored."
  type        = bool
  default     = true
}

variable "existing_resource_group_name" {
  description = "The name of the existing resource group to use. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables."
  type        = string
  default     = null
}

#####################################
# Private Endpoint Configuration   ##
#####################################

variable "enable_private_endpoint" {
  description = "Manages a Private Endpoint to Azure Container Registry. Default is false."
  default     = false
}

variable "existing_dev_private_dns_zone" {
  description = "Name of the existing synapse dev private DNS zone"
  default     = null
}

variable "existing_sql_private_dns_zone" {
  description = "Name of the existing synapse sql private DNS zone"
  default     = null
}

variable "existing_web_private_dns_zone" {
  description = "Name of the existing synapse web private DNS zone"
  default     = null
}

variable "existing_private_subnet_name" {
  description = "Name of the existing subnet for the private endpoint"
  default     = null
}

variable "existing_virtual_network_name" {
  description = "Name of the virtual network for the private endpoint"
  default     = null
}

