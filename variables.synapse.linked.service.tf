# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#########################################
# Synapse Lined Service Configuration  ##
#########################################

variable "linked_services" {
  description = "List over linked services."
  type = list(object({
    name : string
    type : string
    type_properties : map(any)
    additional_properties : optional(map(string), null)
    annotations : optional(list(string), [])
    description : optional(string, "")
    integration_runtime = optional(object({
      name : optional(string, null)
      parameters : optional(map(string), null)
    }), null)
    parameters : optional(map(string), null)
  }))
  default = []
}