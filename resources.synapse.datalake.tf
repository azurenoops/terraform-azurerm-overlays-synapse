# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_storage_data_lake_gen2_filesystem" "datalake" {
  name               = "${local.name}-container"
  storage_account_id = var.storage_data_lake_gen2_id
}
