# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#######################################
# Synapse Spark Pools Configuration  ##
#######################################

variable "spark_pools" {
  description = "A list of Spark pools to create."
  type = list(object({
    name : string
    node_size_family : string
    node_size : string
    node_count : optional(number, null)
    auto_pause_delay_in_minutes : optional(number, 5)
    auto_scale : optional(object({
      max_node_count : number
      min_node_count : number
    }), null)
    cache_size : optional(number, null)
    compute_isolation_enabled : optional(bool, false)
    dynamic_executor_allocation_enabled : optional(bool, true)
    min_executors : optional(number, 1)
    max_executors : optional(number, 2)
    library_requirement : optional(object({
      content : string
      filename : string
    }), null)
    session_level_packages_enabled : optional(bool, false)
    spark_config : optional(object({
      content : string
      filename : string
    }), null)
    spark_log_folder : optional(string, null)
    spark_events_folder : optional(string, null)
    spark_version : optional(string, null)
    tags : optional(map(string), null)
  }))
  default = []
}

