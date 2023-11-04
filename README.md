# Azure Synapse Overlay Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/azurenoops/overlays-template/azurerm/)

This Overlay terraform module can create a an [Azure Synapse workspace](https://docs.microsoft.com/en-us/azure/synapse/) and manage related components (Key Vault, Storage Accounts, Private Endpoints, etc.) to be used in a [SCCA compliant Network](https://registry.terraform.io/modules/azurenoops/overlays-management-hub/azurerm/latest).

## SCCA Compliance

This module can be SCCA compliant and can be used in a SCCA compliant Network. Enable private endpoints and SCCA compliant network rules to make it SCCA compliant.

For more information, please read the [SCCA documentation]("https://www.cisa.gov/secure-cloud-computing-architecture").

## Contributing

If you want to contribute to this repository, feel free to to contribute to our Terraform module.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Using Azure Clouds

Since this module is built for both public and us government clouds. The `environment` variable defaults to `public` for Azure Cloud. When using this module with the Azure Government Cloud, you must set the `environment` variable to `usgovernment`. You will also need to set the azurerm provider `environment` variable to the proper cloud as well. This will ensure that the correct Azure Government Cloud endpoints are used. You will also need to set the `location` variable to a valid Azure Government Cloud location.

Example Usage for Azure Government Cloud:

```hcl

provider "azurerm" {
  environment = "usgovernment"
}

module "overlays-synapse" {
  source  = "azurenoops/overlays-synapse/azurerm"
  version = "2.0.0"
  
  location = "usgovvirginia"
  environment = "usgovernment"
  ...
}

```

## Resources Used

* [Azure Synapse Workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace)
* [Azure Synapse SQL Pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_sql_pool)
* [Azure Synapse Spark Pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_spark_pool)
* [Azure Synapse Linked Service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_linked_service)
* [Azure Synapse Workspace Extended Auditing Policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_extended_auditing_policy)
* [Azure Synapse Workspace Vulnerability Assessment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_vulnerability_assessment)
* [Azure Synapse Workspace Firewall Rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_firewall_rule)
* [Private Endpoints](https://www.terraform.io/docs/providers/azurerm/r/private_endpoint.html)
* [Private DNS zone for `privatelink` A records](https://www.terraform.io/docs/providers/azurerm/r/private_dns_zone.html)
* [Azure Resource Locks](https://www.terraform.io/docs/providers/azurerm/r/management_lock.html)

## Overlay Module Usage

```terraform
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "mod_synapse" {
  source  = "azurenoops/overlays-synapse/azurerm"
  version = "x.x.x"
  
  # By default, this module will create a resource group and 
  # provide a name for an existing resource group. If you wish 
  # to use an existing resource group, change the option 
  # to "create_synapse_resource_group = false." The location of the group 
  # will remain the same if you use the current resource.
  existing_resource_group_name = azurerm_resource_group.synapse_rg.name
  location                     = module.mod_azure_region_lookup.location_cli
  environment                  = var.environment
  deploy_environment           = var.deploy_environment
  org_name                     = var.org_name
  workload_name                = var.workload_name

  # The following variables are used to create a Datalake storage account
  storage_data_lake_gen2_id = azurerm_storage_account.adls.id

  # The following variables are used to create a SQL pool
  sql_administrator_login    = "Example"
  sql_administrator_password = var.sql_administrator_password

  # The following variables are used to create a workspace
  saas_connection                = false
  enable_managed_virtual_network = true

  # The following variables are used to create AAD Linked Tenants
  linking_allowed_for_aad_tenant_ids = []

}

```

## Optional Features

Synapse Overlay has optional features that can be enabled by setting parameters on the deployment.

## Create resource group

By default, this module will create a resource group and the name of the resource group to be given in an argument `existing_resource_group_name`. If you want to use an existing resource group, specify the existing resource group name, and set the argument to `create_synapse_resource_group = false`.

> *If you are using an existing resource group, then this module uses the same resource group location to create all resources in this module.*

## Audit Policy

This module can be used with the [Synapse Workspace Extended Auditing Policy Module](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_extended_auditing_policy) to enable audit policy for the Synapse workspace.

```terraform
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "mod_synapse" {
  source  = "azurenoops/overlays-synapse/azurerm"
  version = "x.x.x"

  # Audit settings 
  auditing_policy_storage_account_id = azurerm_storage_account.logs.id
  audit_retention_in_days            = 30

  # SQL Defender settings 
  sql_defender = {
    retention_days = 30   
    audit_container = {
      name                 = azurerm_storage_container.sql_defender.name
      storage_account_name = azurerm_storage_account.logs.name
      resource_group_name  = azurerm_resource_group.synapse_rg.name
    }
  }
}

```

## SQL Defender

This module can be used with the [Azure Synapse Workspace Vulnerability Assessment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_vulnerability_assessment) to enable SQL Defender Vulnerability Assessment for the Synapse workspace.

```terraform
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "mod_synapse" {
  source  = "azurenoops/overlays-synapse/azurerm"
  version = "x.x.x"

  # Audit settings 
  auditing_policy_storage_account_id = azurerm_storage_account.logs.id
  audit_retention_in_days            = 30

  # SQL Defender settings 
  sql_defender = {
    retention_days = 30   
    recurring_scans = {
      enabled                           = true
      email_subscription_admins_enabled = true
      emails                            = ["example@contoso.com"]
    }
  }
}

```

## Built In SQL Pools

This module can be used with the [Synapse Workspace Module](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace) to create built in SQL pools for the Synapse workspace.

```terraform
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "mod_synapse" {
  source  = "azurenoops/overlays-synapse/azurerm"
  version = "x.x.x"

  # The following variables are used to create a SQL pool
  sql_administrator_login    = "Example"
  sql_administrator_password = var.sql_administrator_password
}

```

## Dedicated SQL Pools

This module can be used with the [Synapse SQL Pool Module](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_sql_pool) to create SQL pools for the Synapse workspace.

```terraform
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "mod_synapse" {
  source  = "azurenoops/overlays-synapse/azurerm"
  version = "x.x.x"

  sql_pools = {
    pool1 = {
      name = "pool1"
      sku_name = "DW1000c"
      max_size_gb = 1024
      tags = {
        environment = "dev"
      }
    }
  }
}

```

## Spark Pools

This module can be used with the [Synapse Spark Pool Module](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_spark_pool) to create Spark pools for the Synapse workspace. 

```terraform
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "mod_synapse" {
  source  = "azurenoops/overlays-synapse/azurerm"
  version = "x.x.x"

  spark_pools = {
    pool1 = {
      name = "pool1"
      node_size = "Small"
      node_count = 3
      tags = {
        environment = "dev"
      }
    }
  }
}

```

## Private Endpoints

This module can be used with the [Private Endpoint Module](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) to create private endpoints for the Synapse workspace. To use this module with private endpoints, you must set the `enable_private_endpoint` variable to `true`. You must also provide the `existing_virtual_network_name` and `existing_private_subnet_name` variables. This will create a private endpoint connection to the Synapse workspace. You can also provide the `existing_dev_private_dns_zone` and `existing_sql_private_dns_zone` variables to use existing private DNS zones for the Synapse workspace. If you do not provide these variables, the module will create private DNS zones for the Synapse workspace.

```terraform
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "mod_synapse" {
  source  = "azurenoops/overlays-synapse/azurerm"
  version = "x.x.x"

  # The following variables are used to create a private endpoint connection
  enable_private_endpoint       = true
  existing_virtual_network_name = azurerm_virtual_network.synapse_vnet.name
  existing_private_subnet_name  = azurerm_subnet.synapse_subnet.name
  existing_dev_private_dns_zone = "privatelink.dev.azuresynapse.net"
  existing_sql_private_dns_zone = "privatelink.sql.azuresynapse.net"
}

```

## Data Lake Storage Gen2

This module can be used with the [Data Lake Storage Gen2 Module](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) to create a Data Lake Storage Gen2 account for the Synapse workspace.  To use this module with a Data Lake Storage Gen2 account, you must set the `storage_data_lake_gen2_id` variable to the ID of the Data Lake Storage Gen2 account. This will create a Data Lake Storage Gen2 account for the Synapse workspace.

```terraform
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "mod_synapse" {
  source  = "azurenoops/overlays-synapse/azurerm"
  version = "x.x.x"

  # The following variables are used to create a Datalake storage account
  storage_data_lake_gen2_id = azurerm_storage_account.adls.id
}

```

## Linked Services

This module can be used with the [Synapse Linked Service Module](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_linked_service) to create linked services for the Synapse workspace. 

```terraform
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "mod_synapse" {
  source  = "azurenoops/overlays-synapse/azurerm"
  version = "x.x.x"

  linked_services =[
    {
      name = "linked_service1"
      type = "AzureSqlDW"
      properties = {
        typeProperties = {
          connectionString = "Server=tcp:myserver.database.windows.net,1433;Initial Catalog=mydatabase;Persist Security Info=False;User ID=mylogin;Password=mypassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
        }
      }
    }
  ]
}

```

## Resource Locks

This module can be used with the [Resource Lock Module](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) to create resource locks for the Synapse workspace.

## Recommended naming and tagging conventions

Applying tags to your Azure resources, resource groups, and subscriptions to logically organize them into a taxonomy. Each tag consists of a name and a value pair. For example, you can apply the name `Environment` and the value `Production` to all the resources in production.
For recommendations on how to implement a tagging strategy, see Resource naming and tagging decision guide.

>**Important** :
Tag names are case-insensitive for operations. A tag with a tag name, regardless of the casing, is updated or retrieved. However, the resource provider might keep the casing you provide for the tag name. You'll see that casing in cost reports. **Tag values are case-sensitive.**

An effective naming convention assembles resource names by using important resource information as parts of a resource's name. For example, using these [recommended naming conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging#example-names), a public IP resource for a production SharePoint workload is named like this: `pip-sharepoint-prod-westus-001`.

<!-- BEGIN_TF_DOCS -->
<!--Run TF Docs-->
<!-- END_TF_DOCS -->