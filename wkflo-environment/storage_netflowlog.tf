resource "random_id" "netflowlog" {
  for_each = var.regions_enabled

  byte_length = 16
}

module "avm-res-storage-storageaccount-netflowlogs" {
  for_each = var.regions_enabled

  source                            = "Azure/avm-res-storage-storageaccount/azurerm"
  version                           = "~>0.6.9"
  enable_telemetry                  = false
  name                              = "st${lower(substr(random_id.netflowlog[each.key].hex, 0, 22))}"
  resource_group_name               = azurerm_resource_group.main[each.key].name
  location                          = each.key
  account_kind                      = "StorageV2"
  account_replication_type          = "ZRS"
  account_tier                      = "Standard"
  access_tier                       = "Hot"
  min_tls_version                   = "TLS1_2"
  cross_tenant_replication_enabled  = false
  is_hns_enabled                    = false
  sftp_enabled                      = false
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = true
  allowed_copy_scope                = "AAD"
  shared_access_key_enabled         = false
  default_to_oauth_authentication   = true
  queue_encryption_key_type         = "Account"
  table_encryption_key_type         = "Account"
  public_network_access_enabled     = true
  allow_nested_items_to_be_public   = false
  tags                              = merge({ usage = "flow_logs_only" }, local.tags, local.data_tags.confidential, { DrataExclude = "NotApplicable" })

  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Deny"
    virtual_network_subnet_ids = distinct(compact(concat(
      [for subnet in module.ubiq_resources.twingate_subnets : subnet.id],
    )))
  }

  blob_properties = {
    container_delete_retention_policy = {
      days = 7
    }
    delete_retention_policy = {
      days = 7
    }
    versioning_enabled = false
  }

  share_properties = {
    retention_policy = {
      days = 7
    }
    smb = {
      authentication_types            = ["Kerberos"]
      channel_encryption_type         = ["AES-256-GCM"]
      kerberos_ticket_encryption_type = ["AES-256"]
      multichannel_enabled            = false
      versions                        = ["SMB3.1.1"]
    }
  }

  managed_identities = {
    user_assigned_resource_ids = [module.avm-res-managedidentity-userassignedidentity-st-netflowlogs[each.key].resource_id]
  }

  customer_managed_key = {
    key_vault_resource_id = module.key_vault[each.key].id
    key_name              = module.key_vault[each.key].keys["net_st_cmk"].name
    user_assigned_identity = {
      resource_id = module.avm-res-managedidentity-userassignedidentity-st-netflowlogs[each.key].resource_id
    }
  }

  role_assignments = {
    nwfl_blob_contributor = {
      role_definition_id_or_name = "Storage Blob Data Contributor"
      principal_id               = module.avm-res-managedidentity-userassignedidentity-nwfl[each.key].principal_id
    }
  }
}
