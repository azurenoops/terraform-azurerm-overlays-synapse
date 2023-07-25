# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

###############
# Outputs    ##
###############

output "cognitive_account_id" {
  value = var.create_cognitive_account ? element(azurerm_cognitive_account.cog.*.id, 0) : null
}
