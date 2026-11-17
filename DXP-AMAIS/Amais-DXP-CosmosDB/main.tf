# TODO: Move role definitions to ubiq-shared-misc-resources in infra-shared repo
# TODO: Import manually created role assigments for "Cosmos DB Account List Keys" into terraform
resource "azurerm_role_definition" "cdb_list_keys" {
  name        = "Cosmos DB Account List Keys"
  scope       = data.azurerm_subscription.main.id
  description = "Provides read access to Cosmos DB Account Keys for identities that need to access data stored within Azure Cosmos DB"

  permissions {
    actions     = ["Microsoft.DocumentDB/databaseAccounts/listKeys/*"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.main.id
  ]
}

resource "azurerm_role_definition" "cdb_manage_tables" {
  name        = "Cosmos DB Manage Cassandra Tables"
  scope       = data.azurerm_subscription.main.id
  description = "Provides full access to Cosmos DB Cassandra tables"

  permissions {
    actions     = ["Microsoft.DocumentDB/databaseAccounts/cassandraKeyspaces/tables/*"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.main.id
  ]
}

module "dxp_cosmosdb_uk" {
  source                      = "./modules/dxp-cosmosdb"
  resource_group_name         = local.resource_group_name
  tags                        = local.common_tags
  cosmosdb_data_classifcation = "confidential"
  az_long_region              = "uksouth"
}

module "dxp_cosmosdb_us" {
  source                      = "./modules/dxp-cosmosdb"
  resource_group_name         = local.resource_group_name
  tags                        = local.common_tags
  cosmosdb_data_classifcation = "confidential"
  az_long_region              = "centralus"
}

module "dxp_cosmosdb_canada" {
  source                      = "./modules/dxp-cosmosdb"
  resource_group_name         = local.resource_group_name
  tags                        = local.common_tags
  cosmosdb_data_classifcation = "confidential"
  az_long_region              = "canadacentral"
}

module "dxp_cosmosdb_germany" {
  source                      = "./modules/dxp-cosmosdb"
  resource_group_name         = local.resource_group_name
  tags                        = local.common_tags
  cosmosdb_data_classifcation = "confidential"
  az_long_region              = "germanywestcentral"
}

module "dxp_cosmosdb_uae" {
  source                      = "./modules/dxp-cosmosdb"
  resource_group_name         = local.resource_group_name
  tags                        = local.common_tags
  cosmosdb_data_classifcation = "confidential"
  az_long_region              = "uaenorth"
}
