# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

provider "azurerm" {
  environment = var.environment
  skip_provider_registration = true
  features {}
}