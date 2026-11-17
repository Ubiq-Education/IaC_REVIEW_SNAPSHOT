<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-amais-site

Module to create the infrastructure required to deploy a Ubiq AMAIS web site.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~>1.14)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~>2.0)

- <a name="requirement_azureactions"></a> [azureactions](#requirement\_azureactions) (~>1.3)

- <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) (~>3.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (<5.0)

- <a name="requirement_bunnynet"></a> [bunnynet](#requirement\_bunnynet) (~>0.19.0)

- <a name="requirement_http"></a> [http](#requirement\_http) (~>3.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (~>3.6)

- <a name="requirement_restful"></a> [restful](#requirement\_restful) (0.25.2)

- <a name="requirement_time"></a> [time](#requirement\_time) (~>0.12)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (~>2.0)

- <a name="provider_azuread"></a> [azuread](#provider\_azuread) (~>3.0)

- <a name="provider_azuread.amais"></a> [azuread.amais](#provider\_azuread.amais) (~>3.0)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (<5.0)

- <a name="provider_azurerm.shared"></a> [azurerm.shared](#provider\_azurerm.shared) (<5.0)

- <a name="provider_bunnynet"></a> [bunnynet](#provider\_bunnynet) (~>0.19.0)

- <a name="provider_http"></a> [http](#provider\_http) (~>3.0)

- <a name="provider_random"></a> [random](#provider\_random) (~>3.6)

- <a name="provider_restful.captcha_prod"></a> [restful.captcha\_prod](#provider\_restful.captcha\_prod) (0.25.2)

- <a name="provider_restful.captcha_staging"></a> [restful.captcha\_staging](#provider\_restful.captcha\_staging) (0.25.2)

- <a name="provider_restful.sendgrid_events_prod"></a> [restful.sendgrid\_events\_prod](#provider\_restful.sendgrid\_events\_prod) (0.25.2)

- <a name="provider_restful.sendgrid_events_staging"></a> [restful.sendgrid\_events\_staging](#provider\_restful.sendgrid\_events\_staging) (0.25.2)

- <a name="provider_terraform"></a> [terraform](#provider\_terraform)

- <a name="provider_time"></a> [time](#provider\_time) (~>0.12)

## Resources

The following resources are used by this module:

- [azapi_resource.main_webapp_staging_webjobs_enabled_linux](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_resource.main_webapp_webjobs_enabled_linux](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_update_resource.azurerm_mssql_server_main_encryption_protector](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [azapi_update_resource.main_webapp_properties](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [azapi_update_resource.main_webapp_properties_linux](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [azapi_update_resource.main_webapp_properties_restrictions_deny](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [azapi_update_resource.main_webapp_staging_properties](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [azapi_update_resource.main_webapp_staging_properties_linux](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [azapi_update_resource.main_webapp_staging_properties_restrictions_deny](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [azuread_app_role_assignment.sso_main_all_ubiq_guests](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) (resource)
- [azuread_application.sso_main](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) (resource)
- [azuread_application_identifier_uri.sso_main](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_identifier_uri) (resource)
- [azuread_group_member.app_amais_sql_rw](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) (resource)
- [azuread_group_member.app_amais_umi](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) (resource)
- [azuread_group_member.sql_entra_dir_r](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) (resource)
- [azuread_service_principal.sso_main](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) (resource)
- [azuread_service_principal_claims_mapping_policy_assignment.sso_main](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_claims_mapping_policy_assignment) (resource)
- [azuread_service_principal_token_signing_certificate.sso_main_1](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_token_signing_certificate) (resource)
- [azuread_service_principal_token_signing_certificate.sso_main_2](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_token_signing_certificate) (resource)
- [azurerm_dns_cname_record.cdn_ams](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) (resource)
- [azurerm_dns_cname_record.cdn_root](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) (resource)
- [azurerm_dns_cname_record.cdn_root_subpath](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) (resource)
- [azurerm_dns_cname_record.cdn_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) (resource)
- [azurerm_eventgrid_system_topic.main_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic) (resource)
- [azurerm_eventgrid_system_topic_event_subscription.slot_swap](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic_event_subscription) (resource)
- [azurerm_key_vault_key.amais](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) (resource)
- [azurerm_key_vault_key.main_sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) (resource)
- [azurerm_key_vault_key.main_sqldb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) (resource)
- [azurerm_key_vault_key.main_st](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) (resource)
- [azurerm_linux_web_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) (resource)
- [azurerm_linux_web_app_slot.main_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app_slot) (resource)
- [azurerm_management_lock.main_sqldb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_mssql_database.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) (resource)
- [azurerm_mssql_firewall_rule.main_azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) (resource)
- [azurerm_mssql_firewall_rule.main_custom](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) (resource)
- [azurerm_mssql_firewall_rule.main_secure_access_gw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) (resource)
- [azurerm_mssql_server.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) (resource)
- [azurerm_mssql_virtual_network_rule.main_vnet_amais](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_network_rule) (resource)
- [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_role_assignment.main_app_dxp_blob_data_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.main_st_app_blob_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.main_st_sql_blob_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_service_plan.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) (resource)
- [azurerm_storage_account_customer_managed_key.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) (resource)
- [azurerm_storage_account_static_website.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_static_website) (resource)
- [azurerm_storage_blob.ai_config_blob_production](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) (resource)
- [azurerm_storage_blob.ai_config_blob_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) (resource)
- [azurerm_storage_blob.config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) (resource)
- [azurerm_storage_blob.static_files](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) (resource)
- [azurerm_storage_container.additional_containers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) (resource)
- [azurerm_storage_container.dxp_ai](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) (resource)
- [azurerm_storage_management_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) (resource)
- [azurerm_storage_table_entity.amais_site](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table_entity) (resource)
- [azurerm_windows_web_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app) (resource)
- [azurerm_windows_web_app_slot.main_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app_slot) (resource)
- [bunnynet_pullzone_hostname.custom](https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_hostname) (resource)
- [random_id.captcha_site](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_id.main](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_id.sendgrid_events_site](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_password.sql_admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
- [restful_operation.captcha_origins_prod](https://registry.terraform.io/providers/magodo/restful/0.25.2/docs/resources/operation) (resource)
- [restful_operation.captcha_origins_staging](https://registry.terraform.io/providers/magodo/restful/0.25.2/docs/resources/operation) (resource)
- [restful_operation.captcha_site_key_rotation_prod](https://registry.terraform.io/providers/magodo/restful/0.25.2/docs/resources/operation) (resource)
- [restful_operation.captcha_site_key_rotation_staging](https://registry.terraform.io/providers/magodo/restful/0.25.2/docs/resources/operation) (resource)
- [restful_operation.captcha_site_prod](https://registry.terraform.io/providers/magodo/restful/0.25.2/docs/resources/operation) (resource)
- [restful_operation.captcha_site_staging](https://registry.terraform.io/providers/magodo/restful/0.25.2/docs/resources/operation) (resource)
- [restful_operation.sendgrid_events_site_key_rotation_prod](https://registry.terraform.io/providers/magodo/restful/0.25.2/docs/resources/operation) (resource)
- [restful_operation.sendgrid_events_site_key_rotation_staging](https://registry.terraform.io/providers/magodo/restful/0.25.2/docs/resources/operation) (resource)
- [restful_operation.sendgrid_events_site_prod](https://registry.terraform.io/providers/magodo/restful/0.25.2/docs/resources/operation) (resource)
- [restful_operation.sendgrid_events_site_staging](https://registry.terraform.io/providers/magodo/restful/0.25.2/docs/resources/operation) (resource)
- [terraform_data.captcha_site_name](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) (resource)
- [terraform_data.sendgrid_events_site_name](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) (resource)
- [terraform_data.web_domains](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) (resource)
- [time_offset.sso_cert_1](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/offset) (resource)
- [time_offset.sso_cert_2](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/offset) (resource)
- [time_rotating.sso_cert_1](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) (resource)
- [time_rotating.sso_cert_2](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) (resource)
- [time_sleep.azurerm_key_vault_key_all](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [time_sleep.azurerm_managedidentity_all](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [time_sleep.azurerm_mssql_server](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [time_sleep.cdn_dns](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [time_sleep.cdn_dns_ams](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [time_sleep.diagnostics_migration](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [time_sleep.kv](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [azuread_application.ckeditor_api_prod](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application) (data source)
- [azuread_application.ckeditor_api_staging](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application) (data source)
- [azuread_application.dxp_api_production](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application) (data source)
- [azuread_application.dxp_api_staging](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application) (data source)
- [azuread_group.amais_app_umi](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) (data source)
- [azuread_group.amais_sql_rw](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) (data source)
- [azuread_group.entra_dir_r](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) (data source)
- [azuread_group.sql_admins](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) (data source)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_dns_zone.static_amais_com](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/dns_zone) (data source)
- [azurerm_dns_zone.website_amais_com](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/dns_zone) (data source)
- [azurerm_key_vault.shared](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) (data source)
- [azurerm_key_vault_key.main_sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_key) (data source)
- [azurerm_key_vault_key.main_sqldb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_key) (data source)
- [azurerm_key_vault_secret.amais_dxp_production_aiclientoauthsettings_clientid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_production_aiclientoauthsettings_clientsecret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_production_ingressclientoauthsettings_clientid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_production_ingressclientoauthsettings_clientsecret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_production_masterdataclientoauthsettings_clientid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_production_masterdataclientoauthsettings_clientsecret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_production_reportclientoauthsettings_clientid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_production_reportclientoauthsettings_clientsecret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_staging_aiclientoauthsettings_clientid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_staging_aiclientoauthsettings_clientsecret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_staging_ingressclientoauthsettings_clientid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_staging_ingressclientoauthsettings_clientsecret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_staging_masterdataclientoauthsettings_clientid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_staging_masterdataclientoauthsettings_clientsecret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_staging_reportclientoauthsettings_clientid](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.amais_dxp_staging_reportclientoauthsettings_clientsecret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.bunnynet_api_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.ckeditor_apikey_prod](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.ckeditor_apikey_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.ckeditor_secretkey_prod](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.ckeditor_secretkey_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.devconfig_ubiq_captcha](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.google_fonts_shared_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.oauth_blackbaud_client_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.oauth_blackbaud_client_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.oauth_blackbaud_subscription_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.send_grid_key_prod](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.send_grid_key_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.site_production_dxp_api_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.site_staging_dxp_api_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.stripeapikey_production](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.stripeapikey_test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.stripepublickey_production](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.stripepublickey_test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.ubiq_captcha_admin_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.ubiq_sendgrid_events_admin_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.ubiq_shortener_api_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_key_vault_secret.zendesk_jwt_shared_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_mssql_server.central_amais](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/mssql_server) (data source)
- [azurerm_redis_cache.eus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/redis_cache) (data source)
- [azurerm_redis_cache.uks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/redis_cache) (data source)
- [azurerm_servicebus_namespace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/servicebus_namespace) (data source)
- [azurerm_storage_account.configs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) (data source)
- [azurerm_storage_account.uks_dxp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) (data source)
- [azurerm_storage_container.configs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_container) (data source)
- [azurerm_storage_table_entities.amais_site_key_in_use](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_table_entities) (data source)
- [azurerm_subnet.vnet_integration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) (data source)
- [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) (data source)
- [azurerm_user_assigned_identity.ais_srch](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) (data source)
- [azurerm_user_assigned_identity.dxp_client_production](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) (data source)
- [azurerm_user_assigned_identity.dxp_client_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) (data source)
- [http_http.captcha_assets](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) (data source)
- [http_http.staticweb_files](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_site_name"></a> [site\_name](#input\_site\_name)

Description: The name of the site, used for resource naming.

Type: `string`

### <a name="input_sub_id"></a> [sub\_id](#input\_sub\_id)

Description: The guid id of the subscription in which to deploy this site.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_BlackbaudSynchAthleticsUpdateJobSetting_schedule"></a> [BlackbaudSynchAthleticsUpdateJobSetting\_schedule](#input\_BlackbaudSynchAthleticsUpdateJobSetting\_schedule)

Description: The cron expression for the Blackbaud Synch Athletics Update Job Settings (Scheduler\_\_BlackbaudSynchAthleticsUpdateJob)

Type: `string`

Default: `"0 0 11-23 * * ?"`

### <a name="input_BlackbaudSynchAthleticsUpdateJobSetting_slot_name"></a> [BlackbaudSynchAthleticsUpdateJobSetting\_slot\_name](#input\_BlackbaudSynchAthleticsUpdateJobSetting\_slot\_name)

Description: Which slot to enable the Blackbaud Synch Job Settings on, either production or staging

Type: `string`

Default: `"production"`

### <a name="input_BlackbaudSynchJobSettings_schedule"></a> [BlackbaudSynchJobSettings\_schedule](#input\_BlackbaudSynchJobSettings\_schedule)

Description: The cron expression for the Blackbaud Synch Job Settings (Scheduler\_\_BlackbaudSynchJob)

Type: `string`

Default: `"0 0 4 * * ?"`

### <a name="input_BlackbaudSynchJobSettings_slot_name"></a> [BlackbaudSynchJobSettings\_slot\_name](#input\_BlackbaudSynchJobSettings\_slot\_name)

Description: Which slot to enable the Blackbaud Synch Job Settings on, either production or staging

Type: `string`

Default: `"production"`

### <a name="input_EmailStatsSyncJobSettings_slot_name"></a> [EmailStatsSyncJobSettings\_slot\_name](#input\_EmailStatsSyncJobSettings\_slot\_name)

Description: Which slot to enable the EmailStats Sync Job Settings on, either production or staging

Type: `string`

Default: `"production"`

### <a name="input_EmailStats_sync_job_schedule_cron_expression"></a> [EmailStats\_sync\_job\_schedule\_cron\_expression](#input\_EmailStats\_sync\_job\_schedule\_cron\_expression)

Description: The cron expression for the EmailStats Sync Job Settings - Scheduler\_\_EmailStatsSyncJob

Type: `string`

Default: `"0 0/30 * * * ?"`

### <a name="input_EmailSupressionsSyncJobSettings_slot_name"></a> [EmailSupressionsSyncJobSettings\_slot\_name](#input\_EmailSupressionsSyncJobSettings\_slot\_name)

Description: Which slot to enable the EmailSupressions Sync Job Settings on, either production or staging

Type: `string`

Default: `"production"`

### <a name="input_EmailSupressions_sync_job_schedule_cron_expression"></a> [EmailSupressions\_sync\_job\_schedule\_cron\_expression](#input\_EmailSupressions\_sync\_job\_schedule\_cron\_expression)

Description: The cron expression for the EmailSupressions Sync Job Settings - Scheduler\_\_EmailSupressionsSyncJob

Type: `string`

Default: `"0 0 0/1 * * ?"`

### <a name="input_VeracrossSynchJobSettings_slot_name"></a> [VeracrossSynchJobSettings\_slot\_name](#input\_VeracrossSynchJobSettings\_slot\_name)

Description: Which slot to enable the Veracross Synch Job Settings on, either production or staging

Type: `string`

Default: `"production"`

### <a name="input_WorkflowEngineJob_schedule_cron_expression"></a> [WorkflowEngineJob\_schedule\_cron\_expression](#input\_WorkflowEngineJob\_schedule\_cron\_expression)

Description: The cron expression for the WorkflowEngineJob Synch Job Settings - Scheduler\_\_WorkflowEngineJob

Type: `string`

Default: `"0 0/10 * * * ?"`

### <a name="input_WorkflowEngineJob_slot_name"></a> [WorkflowEngineJob\_slot\_name](#input\_WorkflowEngineJob\_slot\_name)

Description: Which slot to enable the WorkflowEngineJob schedule on, either production or staging

Type: `string`

Default: `"production"`

### <a name="input_add_delete_locks"></a> [add\_delete\_locks](#input\_add\_delete\_locks)

Description: Add delete locks to important resources

Type: `bool`

Default: `true`

### <a name="input_additional_storage_containers"></a> [additional\_storage\_containers](#input\_additional\_storage\_containers)

Description:   A list of additional storage containers to add to the main storage account.

  ```terraform
  additional_containers = [
    {
      name  = "container1"
      access_type = "private"
    },
    {
      name  = "container2"
      access_type = "blob"
    }
  ]
```

Type:

```hcl
list(object({
    name        = string
    access_type = string
  }))
```

Default: `[]`

### <a name="input_ai_chatbot_embedding_model_production"></a> [ai\_chatbot\_embedding\_model\_production](#input\_ai\_chatbot\_embedding\_model\_production)

Description: The embedding model to use with the AI chatbot on the production slot

Type: `string`

Default: `"text-embedding-3-large"`

### <a name="input_ai_chatbot_embedding_model_staging"></a> [ai\_chatbot\_embedding\_model\_staging](#input\_ai\_chatbot\_embedding\_model\_staging)

Description: The embedding model to use with the AI chatbot on the staging slot (dev sites only)

Type: `string`

Default: `"text-embedding-3-large"`

### <a name="input_ai_chatbot_model_production"></a> [ai\_chatbot\_model\_production](#input\_ai\_chatbot\_model\_production)

Description: The model to use for the AI chatbot on the production slot

Type: `string`

Default: `"gpt-4.1-mini"`

### <a name="input_ai_chatbot_model_staging"></a> [ai\_chatbot\_model\_staging](#input\_ai\_chatbot\_model\_staging)

Description: The model to use for the AI chatbot on the staging slot (dev sites only)

Type: `string`

Default: `"gpt-4.1-mini"`

### <a name="input_allow_public_blobs"></a> [allow\_public\_blobs](#input\_allow\_public\_blobs)

Description: Allow public access to blobs in the storage account

Type: `bool`

Default: `false`

### <a name="input_amais_application_name"></a> [amais\_application\_name](#input\_amais\_application\_name)

Description:   Optional: The name of the application, used by the CMS and DXP.  
  If not supplied will default to the site\_name.

Type: `string`

Default: `null`

### <a name="input_amais_health_check_alert_enabled"></a> [amais\_health\_check\_alert\_enabled](#input\_amais\_health\_check\_alert\_enabled)

Description: Enable or disable the standard health check alert

Type: `bool`

Default: `true`

### <a name="input_amais_response_time_alert_enabled"></a> [amais\_response\_time\_alert\_enabled](#input\_amais\_response\_time\_alert\_enabled)

Description: Enable or disable the standard response time alert

Type: `bool`

Default: `true`

### <a name="input_amais_server_errors_alert_enabled"></a> [amais\_server\_errors\_alert\_enabled](#input\_amais\_server\_errors\_alert\_enabled)

Description: Enable or disable the standard server errors alert

Type: `bool`

Default: `true`

### <a name="input_amais_vnet_alias"></a> [amais\_vnet\_alias](#input\_amais\_vnet\_alias)

Description: The alias for the AMAIS virtual network

Type: `string`

Default: `"amais-01"`

### <a name="input_app_instance_count"></a> [app\_instance\_count](#input\_app\_instance\_count)

Description:   The number of instances to run the app service on, if null will default to the number of zones in the region.  
  Only takes effect if enable\_zone\_redundant\_app\_service is true.

Type: `number`

Default: `null`

### <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings)

Description:   A map of key-value pairs for additional app settings and custom values to assign to the web app,  
  these will be merged with the default settings.  
  The settings supplied to the variable will override the default settings if a key name matches.

  ```terraform
  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_TIME_ZONE            = "Pacific Standard Time"
    WEB_CONCURRENCY              = "1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE_LOCKED = "false"
    WEBSITE_NODE_DEFAULT_VERSION_LOCKED = "false"
    WEBSITE_TIME_ZONE_LOCKED = "false"
    WEB_CONCURRENCY_LOCKED = "false"
    WEBSITE_RUN_FROM_PACKAGE_LOCKED = "false"
  }
```

Type: `map(string)`

Default: `{}`

### <a name="input_app_settings_staging"></a> [app\_settings\_staging](#input\_app\_settings\_staging)

Description:   A map of key-value pairs for additional app settings and custom values to assign to the web app staging slot (if created),  
  these will be merged with the default settings.  
  The settings supplied to the variable will override the default settings if a key name matches

  ```terraform
  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_TIME_ZONE            = "Pacific Standard Time"
    WEB_CONCURRENCY              = "1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE_LOCKED = "false"
    WEBSITE_NODE_DEFAULT_VERSION_LOCKED = "false"
    WEBSITE_TIME_ZONE_LOCKED = "false"
    WEB_CONCURRENCY_LOCKED = "false"
    WEBSITE_RUN_FROM_PACKAGE_LOCKED = "false"
  }
```

Type: `map(string)`

Default: `{}`

### <a name="input_app_stack_dotnet_version"></a> [app\_stack\_dotnet\_version](#input\_app\_stack\_dotnet\_version)

Description: The version of .NET to use for the stack settings

Type: `string`

Default: `"v10.0"`

### <a name="input_app_stack_dotnet_version_staging"></a> [app\_stack\_dotnet\_version\_staging](#input\_app\_stack\_dotnet\_version\_staging)

Description: The version of .NET to use for the stack settings staging slot, if null will use the same as the main app.

Type: `string`

Default: `null`

### <a name="input_app_sticky_settings_names"></a> [app\_sticky\_settings\_names](#input\_app\_sticky\_settings\_names)

Description: Optional: A list of sticky settings to assign to the web app in addition to the default list.

Type: `list(string)`

Default: `[]`

### <a name="input_authorize_net_api_login_id"></a> [authorize\_net\_api\_login\_id](#input\_authorize\_net\_api\_login\_id)

Description: The Authorize.Net API login ID

Type: `string`

Default: `null`

### <a name="input_authorize_net_public_client_key"></a> [authorize\_net\_public\_client\_key](#input\_authorize\_net\_public\_client\_key)

Description: The Authorize.Net public client key

Type: `string`

Default: `null`

### <a name="input_authorize_net_transaction_key"></a> [authorize\_net\_transaction\_key](#input\_authorize\_net\_transaction\_key)

Description: The Authorize.Net transaction key

Type: `string`

Default: `null`

### <a name="input_az_long_region"></a> [az\_long\_region](#input\_az\_long\_region)

Description: Azure region name, e.g eastus, southcentralus, uksouth, etc.

Type: `string`

Default: `"uksouth"`

### <a name="input_azuread_amais_client_id"></a> [azuread\_amais\_client\_id](#input\_azuread\_amais\_client\_id)

Description: The client id for the AMAIS SSO Entra tenant application.

Type: `string`

Default: `null`

### <a name="input_azuread_amais_client_secret"></a> [azuread\_amais\_client\_secret](#input\_azuread\_amais\_client\_secret)

Description: The client secret for the AMAIS SSO Entra tenant application.

Type: `string`

Default: `null`

### <a name="input_azuread_amais_tenant_id"></a> [azuread\_amais\_tenant\_id](#input\_azuread\_amais\_tenant\_id)

Description: The tenant id for the AMAIS SSO Entra tenant.

Type: `string`

Default: `"414ca595-4008-478e-a036-953f19733f2e"`

### <a name="input_blackbaud_account_name"></a> [blackbaud\_account\_name](#input\_blackbaud\_account\_name)

Description: The Blackbaud account name

Type: `string`

Default: `null`

### <a name="input_blackbaud_oauth_sso_api_key_production"></a> [blackbaud\_oauth\_sso\_api\_key\_production](#input\_blackbaud\_oauth\_sso\_api\_key\_production)

Description: The production slot Blackbaud OAuth API key for SSO integration

Type: `string`

Default: `null`

### <a name="input_blackbaud_oauth_sso_api_key_staging"></a> [blackbaud\_oauth\_sso\_api\_key\_staging](#input\_blackbaud\_oauth\_sso\_api\_key\_staging)

Description: The staging slot Blackbaud OAuth API key for SSO integration

Type: `string`

Default: `null`

### <a name="input_blackbaud_sso_auth_api_slug_production"></a> [blackbaud\_sso\_auth\_api\_slug\_production](#input\_blackbaud\_sso\_auth\_api\_slug\_production)

Description: The Blackbaud SSO Auth API slug to append to the SSO URL for production slot Blackbaud integration

Type: `string`

Default: `null`

### <a name="input_blackbaud_sso_auth_api_slug_staging"></a> [blackbaud\_sso\_auth\_api\_slug\_staging](#input\_blackbaud\_sso\_auth\_api\_slug\_staging)

Description: The Blackbaud SSO Auth API slug to append to the SSO URL for staging slot Blackbaud integration

Type: `string`

Default: `null`

### <a name="input_bot_detection_disable_paths"></a> [bot\_detection\_disable\_paths](#input\_bot\_detection\_disable\_paths)

Description: A list of URL paths to disable Bunny bot detection

Type: `list(string)`

Default: `[]`

### <a name="input_bunny_cdn_enablement"></a> [bunny\_cdn\_enablement](#input\_bunny\_cdn\_enablement)

Description:   Enablement of Bunny CDN. Options are 'yes' or 'no'
  - 'no' will disable Bunny CDN and route traffic directly to the web app and storage hosts
  - 'yes' will enable Bunny CDN and use Bunny-backed hostnames

Type: `string`

Default: `"yes"`

### <a name="input_bunny_pullzone_additional_edge_rules"></a> [bunny\_pullzone\_additional\_edge\_rules](#input\_bunny\_pullzone\_additional\_edge\_rules)

Description:   Optional: Additional Bunny CDN edge rules to apply.  
  Priority is an integer value that determines the order of the rules, starting at 1.  
  The specified priority will be used to order the additional rules relative to each other.  
  Rules will be added after the default rules.

Type:

```hcl
map(object({
    description = string
    enabled     = optional(bool, true)
    priority    = number
    actions = list(object({
      type       = string
      parameter1 = optional(string)
      parameter2 = optional(string)
      parameter3 = optional(string)
    }))
    match_type = string
    triggers = list(object({
      type       = string
      match_type = string
      patterns   = list(string)
      parameter1 = optional(string)
      parameter2 = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_bunny_pullzone_additional_rate_limit_rules"></a> [bunny\_pullzone\_additional\_rate\_limit\_rules](#input\_bunny\_pullzone\_additional\_rate\_limit\_rules)

Description:   Optional: Pull zone shield rate limit rules to apply.  
  For valid property values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_ratelimit_rule

Type:

```hcl
map(object({
    name            = string
    description     = string
    transformations = optional(list(string))
    condition = map(object({
      operator       = string
      value          = string
      variable       = string
      variable_value = optional(string)
    }))
    limit = object({
      requests = number
      interval = optional(number, 1)
    })
    response = object({
      interval = optional(number, 60)
    })
  }))
```

Default: `{}`

### <a name="input_bunny_pullzone_base_rate_limit_rule"></a> [bunny\_pullzone\_base\_rate\_limit\_rule](#input\_bunny\_pullzone\_base\_rate\_limit\_rule)

Description: Values for the base rate limit configuration for the Bunny pull zone shield

Type:

```hcl
object({
    enabled                = optional(bool, true)
    requests_per_second    = optional(number)
    block_duration_seconds = optional(number)
  })
```

Default: `{}`

### <a name="input_bunny_pullzone_config"></a> [bunny\_pullzone\_config](#input\_bunny\_pullzone\_config)

Description:   Configuration for the bunny pullzone.  
  For valid values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone

Type:

```hcl
object({
    pullzone_name              = optional(string)
    cache_enabled              = optional(bool)
    cache_expiration_time      = optional(number)
    cache_errors               = optional(bool)
    cache_vary                 = optional(list(string))
    cache_chunked              = optional(bool)
    cors_enabled               = optional(bool)
    cors_extensions            = optional(list(string))
    add_canonical_header       = optional(bool)
    safehop_enabled            = optional(bool)
    safehop_connection_timeout = optional(number)
    safehop_response_timeout   = optional(number)
    safehop_retry_count        = optional(number)
    safehop_retry_delay        = optional(number)
    safehop_retry_reasons      = optional(list(string))
    block_root_path            = optional(bool)
    sort_querystring           = optional(bool)
    strip_cookies              = optional(bool)
    tls_level                  = optional(string)
    request_coalescing_enabled = optional(bool)
    log_forward_enabled        = optional(bool)
    log_forward_format         = optional(string)
    log_forward_port           = optional(number)
    log_forward_protocol       = optional(string)
    log_forward_server         = optional(string)
    log_forward_token          = optional(string)
    origin = optional(object({
      verify_ssl          = optional(bool)
      follow_redirects    = optional(bool)
      forward_host_header = optional(bool)
      host_header         = optional(string)
      middleware_script   = optional(number)
    }))
    routing = optional(object({
      tier              = optional(string)
      zones             = optional(list(string))
      blocked_countries = optional(list(string))
    }))
    optimizer_enabled                     = optional(bool)
    optimizer_webp                        = optional(bool)
    optimizer_dynamic_image_api           = optional(bool)
    optimizer_burrow                      = optional(bool)
    optimizer_classes_force               = optional(bool)
    optimizer_html_prerender              = optional(bool)
    optimizer_minify_css                  = optional(bool)
    optimizer_minify_js                   = optional(bool)
    optimizer_smartimage                  = optional(bool)
    optimizer_smartimage_desktop_maxwidth = optional(number)
    optimizer_smartimage_desktop_quality  = optional(number)
    optimizer_smartimage_mobile_maxwidth  = optional(number)
    optimizer_smartimage_mobile_quality   = optional(number)
    optimizer_watermark                   = optional(bool)
    optimizer_watermark_borderoffset      = optional(number)
    optimizer_watermark_minsize           = optional(number)
    optimizer_watermark_position          = optional(string)
    optimizer_watermark_url               = optional(string)
  })
```

Default: `{}`

### <a name="input_bunny_pullzone_custom_access_lists"></a> [bunny\_pullzone\_custom\_access\_lists](#input\_bunny\_pullzone\_custom\_access\_lists)

Description:   Optional: Access lists to apply to the Bunny pull zone.  
  Merged after built-in access lists, including the Ubiq secure gateway IP Shield bypass list (ubiq\_secure\_access\_gateways).  
  For valid property values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_access_list

Type:

```hcl
map(object({
    name    = string
    action  = string
    type    = string
    entries = set(string)
    enabled = optional(bool, true)
  }))
```

Default: `{}`

### <a name="input_bunny_pullzone_custom_waf_rules"></a> [bunny\_pullzone\_custom\_waf\_rules](#input\_bunny\_pullzone\_custom\_waf\_rules)

Description:   Optional: Pull zone shield waf rules to apply.  
  For valid property values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_waf_rule

Type:

```hcl
map(object({
    name            = string
    description     = string
    transformations = optional(list(string))
    condition = map(object({
      operator       = string
      value          = string
      variable       = string
      variable_value = optional(string)
    }))
    response = object({
      action = string
    })
  }))
```

Default: `{}`

### <a name="input_bunny_pullzone_shield_config"></a> [bunny\_pullzone\_shield\_config](#input\_bunny\_pullzone\_shield\_config)

Description:   Optional: Custom configuration for the Bunny pull zone shield, defaults will be used for values not supplied.  
  For valid values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_shield

Type:

```hcl
object({
    tier                      = optional(string)
    whitelabel                = optional(bool)
    whitelabel_block          = optional(string)
    whitelabel_challenge      = optional(string)
    whitelabel_rate_limit     = optional(string)
    upload_scanning_antivirus = optional(string)
    upload_scanning_csam      = optional(string)
    ddos = optional(object({
      level            = optional(string, "Low")
      challenge_window = optional(number, 3600)
    }))
    waf = optional(object({
      # Ensure variable defaults matches the default in bunny.waf for an empty variable for consistency
      enabled                       = optional(bool)
      allowed_http_methods          = optional(list(string), ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
      allowed_http_versions         = optional(list(string))
      allowed_request_content_types = optional(list(string))
      blocking_sensitivity          = optional(number)
      body_limit_request            = optional(string)
      body_limit_response           = optional(string)
      detection_sensitivity         = optional(number)
      execution_sensitivity         = optional(number)
      log_headers                   = optional(bool)
      log_headers_excluded          = optional(list(string))
      mode                          = optional(string, "Block")
      realtime_threat_intelligence  = optional(bool)
      rules_disabled                = optional(list(string), ["952100", "953100", "953101", "953110", "953120", "DDoS-0ad5f8", "SHL-G8", "941160", "932125"])
      rules_logonly                 = optional(list(string), ["932235", "941100", "921130", "933120", "942100", "942550", "932370", "951120"])
    }))
    bot_detection = optional(object({
      complex_fingerprinting  = optional(bool)
      fingerprint_aggression  = optional(number)
      fingerprint_sensitivity = optional(number)
      ip_sensitivity          = optional(number)
      mode                    = optional(string, "Challenge")
      request_integrity       = optional(number)
    }))
    bot_categorization = optional(list(object({
      category = string
      action   = string
      overrides = optional(list(object({
        bot    = string
        action = string
      })))
    })))
    access_list = optional(set(object({
      action = string
      id     = number
    })), [])
  })
```

Default:

```json
{
  "bot_detection": {
    "mode": "Challenge"
  },
  "ddos": {
    "level": "Low"
  },
  "tier": "Advanced",
  "waf": {
    "enabled": true,
    "mode": "Block"
  }
}
```

### <a name="input_calendar_time_zone"></a> [calendar\_time\_zone](#input\_calendar\_time\_zone)

Description: The time zone for the calendar module

Type: `string`

Default: `null`

### <a name="input_calendar_time_zone_id"></a> [calendar\_time\_zone\_id](#input\_calendar\_time\_zone\_id)

Description: The time zone ID for the calendar module

Type: `string`

Default: `null`

### <a name="input_captcha_site_key_rotation_increment"></a> [captcha\_site\_key\_rotation\_increment](#input\_captcha\_site\_key\_rotation\_increment)

Description:   Keep at 0 during initial provisioning; then monotonically increment by exactly one to rotate the site's captcha  
  site key. The previous key stays valid until the next rotation, so don't rotate twice inside the web app's Key Vault  
  reference refresh window. Never decrease or reuse a prior value. If it is reset to 0 by mistake the stored key  
  reverts to the original registration key, which is no longer valid: set any value of 1 or more to rotate again.

Type: `number`

Default: `0`

### <a name="input_create_staging_slot"></a> [create\_staging\_slot](#input\_create\_staging\_slot)

Description: Create the staging slot for the web app

Type: `bool`

Default: `true`

### <a name="input_custom_cors_allowed_origins"></a> [custom\_cors\_allowed\_origins](#input\_custom\_cors\_allowed\_origins)

Description: Optional: A list of URLs to add to the CORs allowed origin list on the web app. URLs will be added to both slots.

Type: `list(string)`

Default: `[]`

### <a name="input_dev_site"></a> [dev\_site](#input\_dev\_site)

Description: Whether this is a dev site or not, and what type.

Type: `string`

Default: `"no"`

### <a name="input_directory_and_sso_integration_provider"></a> [directory\_and\_sso\_integration\_provider](#input\_directory\_and\_sso\_integration\_provider)

Description:   Provider to use for directory and SSO integration, supported providers are:

  Blackbaud  
  Veracross  
  GG4L

Type: `string`

Default: `null`

### <a name="input_disable_branch_redirects_production"></a> [disable\_branch\_redirects\_production](#input\_disable\_branch\_redirects\_production)

Description: Disable branch redirects on the production slot (DISABLE\_BRANCH\_REDIRECTS = 'true')

Type: `bool`

Default: `false`

### <a name="input_disable_branch_redirects_staging"></a> [disable\_branch\_redirects\_staging](#input\_disable\_branch\_redirects\_staging)

Description: Disable branch redirects on the staging slot (DISABLE\_BRANCH\_REDIRECTS = 'true')

Type: `bool`

Default: `true`

### <a name="input_enable_BlackbaudSynchAthleticsUpdateJobSetting"></a> [enable\_BlackbaudSynchAthleticsUpdateJobSetting](#input\_enable\_BlackbaudSynchAthleticsUpdateJobSetting)

Description: Enable or disable the Blackbaud Synch Athletics Update Job Settings

Type: `bool`

Default: `false`

### <a name="input_enable_BlackbaudSynchJobSettings"></a> [enable\_BlackbaudSynchJobSettings](#input\_enable\_BlackbaudSynchJobSettings)

Description: Enable or disable the Blackbaud Synch Job Settings

Type: `bool`

Default: `true`

### <a name="input_enable_VeracrossSynchJobSettings"></a> [enable\_VeracrossSynchJobSettings](#input\_enable\_VeracrossSynchJobSettings)

Description: Enable or disable the Veracross Synch Job Settings - VeracrossSynchJobSettings\_\_IsEnable

Type: `bool`

Default: `false`

### <a name="input_enable_ai_chatbot_production"></a> [enable\_ai\_chatbot\_production](#input\_enable\_ai\_chatbot\_production)

Description: Enable or disable the AI chatbot on the production slot

Type: `bool`

Default: `false`

### <a name="input_enable_ai_chatbot_staging"></a> [enable\_ai\_chatbot\_staging](#input\_enable\_ai\_chatbot\_staging)

Description: Enable or disable the AI chatbot on the staging slot

Type: `bool`

Default: `false`

### <a name="input_enable_authorize_net_integration_production"></a> [enable\_authorize\_net\_integration\_production](#input\_enable\_authorize\_net\_integration\_production)

Description:   Enable or disable the Authorize.Net integration on the production slot.  
  If enabled, the following variables must be set:

  authorize\_net\_api\_login\_id  
  authorize\_net\_public\_client\_key  
  authorize\_net\_transaction\_key

Type: `bool`

Default: `false`

### <a name="input_enable_authorize_net_integration_staging"></a> [enable\_authorize\_net\_integration\_staging](#input\_enable\_authorize\_net\_integration\_staging)

Description:   Enable or disable the Authorize.Net integration on the staging slot.  
  If enabled, the following variables must be set:

  authorize\_net\_api\_login\_id  
  authorize\_net\_public\_client\_key  
  authorize\_net\_transaction\_key

Type: `bool`

Default: `false`

### <a name="input_enable_blackbaud_sso"></a> [enable\_blackbaud\_sso](#input\_enable\_blackbaud\_sso)

Description: Enable Single Sign-On (SSO) for Blackbaud integration

Type: `bool`

Default: `false`

### <a name="input_enable_contacts_module_production"></a> [enable\_contacts\_module\_production](#input\_enable\_contacts\_module\_production)

Description: Enable or disable the contacts module on the production slot

Type: `bool`

Default: `false`

### <a name="input_enable_contacts_module_staging"></a> [enable\_contacts\_module\_staging](#input\_enable\_contacts\_module\_staging)

Description: Enable or disable the contacts module on the staging slot

Type: `bool`

Default: `false`

### <a name="input_enable_custom_send_grid_config_production"></a> [enable\_custom\_send\_grid\_config\_production](#input\_enable\_custom\_send\_grid\_config\_production)

Description:   Enable or disable custom SendGrid configuration on the production slot.  
  Enabling it also registers the site with the Ubiq SendGrid event receiver and adds the SendGridEvents\_\_* app  
  settings to the production slot.  
  If enabled, the following variables must be set:

  send\_grid\_email\_sender  
  send\_grid\_key  
  send\_grid\_marketing\_unsubscribe\_group\_id  
  send\_grid\_unsubscribe\_groups  
  send\_grid\_user

Type: `bool`

Default: `false`

### <a name="input_enable_custom_send_grid_config_staging"></a> [enable\_custom\_send\_grid\_config\_staging](#input\_enable\_custom\_send\_grid\_config\_staging)

Description:   Enable or disable custom SendGrid configuration on the staging slot.  
  Enabling it also registers the site with the Ubiq SendGrid event receiver and adds the SendGridEvents\_\_* app  
  settings to the staging slot.  
  If enabled, the following variables must be set:

  send\_grid\_email\_sender  
  send\_grid\_key  
  send\_grid\_marketing\_unsubscribe\_group\_id  
  send\_grid\_unsubscribe\_groups  
  send\_grid\_user

Type: `bool`

Default: `false`

### <a name="input_enable_dxp_integration_production"></a> [enable\_dxp\_integration\_production](#input\_enable\_dxp\_integration\_production)

Description: Enable or disable the DXP integration on the production slot

Type: `bool`

Default: `true`

### <a name="input_enable_dxp_integration_staging"></a> [enable\_dxp\_integration\_staging](#input\_enable\_dxp\_integration\_staging)

Description: Enable or disable the DXP integration on the staging slot

Type: `bool`

Default: `true`

### <a name="input_enable_email_module_production"></a> [enable\_email\_module\_production](#input\_enable\_email\_module\_production)

Description: Enable or disable the email module on the production slot

Type: `bool`

Default: `false`

### <a name="input_enable_email_module_staging"></a> [enable\_email\_module\_staging](#input\_enable\_email\_module\_staging)

Description: Enable or disable the email module on the staging slot

Type: `bool`

Default: `false`

### <a name="input_enable_entra_dxp_client_production"></a> [enable\_entra\_dxp\_client\_production](#input\_enable\_entra\_dxp\_client\_production)

Description: Use the platform DXP client managed identities on the production slot for authentication to the DXP

Type: `bool`

Default: `true`

### <a name="input_enable_entra_dxp_client_staging"></a> [enable\_entra\_dxp\_client\_staging](#input\_enable\_entra\_dxp\_client\_staging)

Description: Use the platform DXP client managed identities on the staging slot for authentication to the DXP

Type: `bool`

Default: `true`

### <a name="input_enable_form_payments_production"></a> [enable\_form\_payments\_production](#input\_enable\_form\_payments\_production)

Description: Enable or disable form payments on the production slot

Type: `bool`

Default: `false`

### <a name="input_enable_form_payments_staging"></a> [enable\_form\_payments\_staging](#input\_enable\_form\_payments\_staging)

Description: Enable or disable form payments on the staging slot

Type: `bool`

Default: `false`

### <a name="input_enable_gg4l_directory_synch"></a> [enable\_gg4l\_directory\_synch](#input\_enable\_gg4l\_directory\_synch)

Description: Enable or disable the GG4L directory sync

Type: `bool`

Default: `false`

### <a name="input_enable_gg4l_sso"></a> [enable\_gg4l\_sso](#input\_enable\_gg4l\_sso)

Description: Enable Single Sign-On (SSO) for GG4L integration

Type: `bool`

Default: `false`

### <a name="input_enable_page_data_generation_job_slot"></a> [enable\_page\_data\_generation\_job\_slot](#input\_enable\_page\_data\_generation\_job\_slot)

Description: The slot to enable the page data generation job on, either production, staging or none

Type: `string`

Default: `"none"`

### <a name="input_enable_sql_advanced_auditing"></a> [enable\_sql\_advanced\_auditing](#input\_enable\_sql\_advanced\_auditing)

Description: Enables auditing for the SQL server to blob storage

Type: `bool`

Default: `true`

### <a name="input_enable_sql_azure_firewall_exception"></a> [enable\_sql\_azure\_firewall\_exception](#input\_enable\_sql\_azure\_firewall\_exception)

Description: Enable or disable Azure IPs firewall rule exception for the SQL server

Type: `bool`

Default: `false`

### <a name="input_enable_sql_ms_support_auditing"></a> [enable\_sql\_ms\_support\_auditing](#input\_enable\_sql\_ms\_support\_auditing)

Description: Enables Microsoft support actions auditing for the SQL server to blob storage

Type: `bool`

Default: `true`

### <a name="input_enable_sqldb_advanced_auditing"></a> [enable\_sqldb\_advanced\_auditing](#input\_enable\_sqldb\_advanced\_auditing)

Description: Enables auditing for the SQL database to blob storage

Type: `bool`

Default: `false`

### <a name="input_enable_sqldb_diagnostic_settings"></a> [enable\_sqldb\_diagnostic\_settings](#input\_enable\_sqldb\_diagnostic\_settings)

Description: Enables full diagnostic settings for the SQL database to send logs to Log Analytics

Type: `bool`

Default: `false`

### <a name="input_enable_storage_blob_diagnostic_settings"></a> [enable\_storage\_blob\_diagnostic\_settings](#input\_enable\_storage\_blob\_diagnostic\_settings)

Description: Enables diagnostic settings for the storage account blob service to send logs to Log Analytics

Type: `bool`

Default: `true`

### <a name="input_enable_storage_shared_key_access"></a> [enable\_storage\_shared\_key\_access](#input\_enable\_storage\_shared\_key\_access)

Description: Enable or disable shared key access for the storage account

Type: `bool`

Default: `false`

### <a name="input_enable_veracross_sso"></a> [enable\_veracross\_sso](#input\_enable\_veracross\_sso)

Description: Enable Single Sign-On (SSO) for Veracross integration

Type: `bool`

Default: `false`

### <a name="input_enable_workflow_module_production"></a> [enable\_workflow\_module\_production](#input\_enable\_workflow\_module\_production)

Description: Enable or disable the workflow module on the production slot

Type: `bool`

Default: `false`

### <a name="input_enable_workflow_module_staging"></a> [enable\_workflow\_module\_staging](#input\_enable\_workflow\_module\_staging)

Description: Enable or disable the workflow module on the staging slot

Type: `bool`

Default: `false`

### <a name="input_enable_zone_redundant_app_service"></a> [enable\_zone\_redundant\_app\_service](#input\_enable\_zone\_redundant\_app\_service)

Description:   Enable zone redundancy for the app service plan, this is only supported with premium v2 or v3 plans.  
  Will only take effect if the region supports zones.

Type: `bool`

Default: `false`

### <a name="input_enable_zone_redundant_sql"></a> [enable\_zone\_redundant\_sql](#input\_enable\_zone\_redundant\_sql)

Description: Enable zone redundancy for the SQL server, this is only supported with premium and business critical plans

Type: `bool`

Default: `false`

### <a name="input_gg4l_oauth_settings_client_id"></a> [gg4l\_oauth\_settings\_client\_id](#input\_gg4l\_oauth\_settings\_client\_id)

Description: The value for OAuthSettings\_\_ClientId

Type: `string`

Default: `null`

### <a name="input_gg4l_oauth_settings_client_secret"></a> [gg4l\_oauth\_settings\_client\_secret](#input\_gg4l\_oauth\_settings\_client\_secret)

Description: The value for OAuthSettings\_\_ClientSecret

Type: `string`

Default: `null`

### <a name="input_gg4l_synch_client_id"></a> [gg4l\_synch\_client\_id](#input\_gg4l\_synch\_client\_id)

Description: The value for GG4L\_SynchClientId

Type: `string`

Default: `null`

### <a name="input_gg4l_synch_client_secret"></a> [gg4l\_synch\_client\_secret](#input\_gg4l\_synch\_client\_secret)

Description: The value for GG4L\_SynchClientSecret

Type: `string`

Default: `null`

### <a name="input_google_bot_bypass_enabled"></a> [google\_bot\_bypass\_enabled](#input\_google\_bot\_bypass\_enabled)

Description: Whether to add a Bunny access list that bypasses the shield for Google user-triggered fetcher IP ranges

Type: `bool`

Default: `true`

### <a name="input_https_only_enabled"></a> [https\_only\_enabled](#input\_https\_only\_enabled)

Description: Enable or disable HTTPS only for the web app

Type: `bool`

Default: `true`

### <a name="input_https_only_enabled_staging"></a> [https\_only\_enabled\_staging](#input\_https\_only\_enabled\_staging)

Description: Enable or disable HTTPS only for the web app staging slot

Type: `bool`

Default: `true`

### <a name="input_launch_date"></a> [launch\_date](#input\_launch\_date)

Description:   The launch date and time of the site. The value should be supplied in local UK time.  
  Set to a time more than 1 week in the past to make live immediately.

Type: `string`

Default: `null`

### <a name="input_min_tls_cipher_suite"></a> [min\_tls\_cipher\_suite](#input\_min\_tls\_cipher\_suite)

Description: The minimum TLS cipher suite to use for the web app

Type: `string`

Default: `"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"`

### <a name="input_min_tls_cipher_suite_staging"></a> [min\_tls\_cipher\_suite\_staging](#input\_min\_tls\_cipher\_suite\_staging)

Description: The minimum TLS cipher suite to use for the web app staging slot

Type: `string`

Default: `"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"`

### <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version)

Description: The minimum TLS version to use for the web app

Type: `string`

Default: `"1.2"`

### <a name="input_minimum_tls_version_staging"></a> [minimum\_tls\_version\_staging](#input\_minimum\_tls\_version\_staging)

Description: The minimum TLS version to use for the web app staging slot

Type: `string`

Default: `"1.2"`

### <a name="input_oauth_authorize_url_override"></a> [oauth\_authorize\_url\_override](#input\_oauth\_authorize\_url\_override)

Description: This will override the OAuthSettings\_\_AuthorizeUrl for SSO integrations.

Type: `string`

Default: `null`

### <a name="input_onboard_client_assets"></a> [onboard\_client\_assets](#input\_onboard\_client\_assets)

Description:   Onboard the site to Client Assets when it is created: queues the Client Assets onboarding pipeline, which creates the  
  site's asset repository (named after site\_name), its pipelines and branch policies. It runs only when Terraform  
  creates the site's AMAISSites entity (a new site, or a change of site key), never on update, and the apply does not  
  wait for it. Set to false to skip onboarding. Turning it on or off for an existing site changes nothing.

Type: `bool`

Default: `true`

### <a name="input_page_data_generation_job_cron_expression"></a> [page\_data\_generation\_job\_cron\_expression](#input\_page\_data\_generation\_job\_cron\_expression)

Description: The cron expression for the page data generation job on the production slot

Type: `string`

Default: `"0 0 0 ? * *"`

### <a name="input_provision_from_baseline"></a> [provision\_from\_baseline](#input\_provision\_from\_baseline)

Description:   Start a new site from the Baseline site's content: the latest nightly snapshot of the Baseline database, blob  
  container and static website ($web) are imported once, before the normal database release runs. Content is copied  
  as-is; files the module uploads to $web are kept.  
  It fires whenever Terraform creates the SQL database, including a replacement of an existing database. Once a run has  
  completed, the completion marker it writes (container 'provisioning', blob 'baseline-provision.json' in the site's  
  storage account) makes later runs no-ops, so nothing is copied twice. Do not turn it on for an existing site unless  
  Baseline content is wanted when its database is next re-created. Turning it off changes nothing.  
  Cannot be enabled for the Baseline site itself (site key, the templates folder, 'Baseline').

Type: `bool`

Default: `false`

### <a name="input_resource_metric_alerts_enabled"></a> [resource\_metric\_alerts\_enabled](#input\_resource\_metric\_alerts\_enabled)

Description: Enable or disable the Azure resource metric alerts

Type: `bool`

Default: `true`

### <a name="input_scheduler_manager_job_cron_expression"></a> [scheduler\_manager\_job\_cron\_expression](#input\_scheduler\_manager\_job\_cron\_expression)

Description: The cron expression for the Scheduler Manager Sync Job Settings - Scheduler\_\_ManagerJob

Type: `string`

Default: `"0 0/10 * * * ?"`

### <a name="input_scheduler_manager_slot_name"></a> [scheduler\_manager\_slot\_name](#input\_scheduler\_manager\_slot\_name)

Description: Which slot to enable the Scheduler Manager schedule on, either production or staging

Type: `string`

Default: `"production"`

### <a name="input_scm_minimum_tls_version"></a> [scm\_minimum\_tls\_version](#input\_scm\_minimum\_tls\_version)

Description: The minimum TLS version to use for the SCM site of the web app

Type: `string`

Default: `"1.2"`

### <a name="input_scm_minimum_tls_version_staging"></a> [scm\_minimum\_tls\_version\_staging](#input\_scm\_minimum\_tls\_version\_staging)

Description: The minimum TLS version to use for the SCM site of the web app staging slot

Type: `string`

Default: `"1.2"`

### <a name="input_semrush_bot_bypass_enabled"></a> [semrush\_bot\_bypass\_enabled](#input\_semrush\_bot\_bypass\_enabled)

Description: Whether to add a Bunny access list that bypasses the shield for Semrush IP ranges

Type: `bool`

Default: `true`

### <a name="input_send_grid_email_sender"></a> [send\_grid\_email\_sender](#input\_send\_grid\_email\_sender)

Description: The email address to use as the sender for SendGrid emails for custom SendGrid configuration

Type: `string`

Default: `null`

### <a name="input_send_grid_key_production"></a> [send\_grid\_key\_production](#input\_send\_grid\_key\_production)

Description: The production slot SendGrid API key for custom SendGrid configuration

Type: `string`

Default: `null`

### <a name="input_send_grid_key_staging"></a> [send\_grid\_key\_staging](#input\_send\_grid\_key\_staging)

Description: The staging slot SendGrid API key for custom SendGrid configuration

Type: `string`

Default: `null`

### <a name="input_send_grid_marketing_unsubscribe_group_id"></a> [send\_grid\_marketing\_unsubscribe\_group\_id](#input\_send\_grid\_marketing\_unsubscribe\_group\_id)

Description: The SendGrid marketing unsubscribe group ID for custom SendGrid configuration

Type: `string`

Default: `null`

### <a name="input_send_grid_unsubscribe_groups"></a> [send\_grid\_unsubscribe\_groups](#input\_send\_grid\_unsubscribe\_groups)

Description:   A json blob of SendGrid unsubscribe group names for custom SendGrid configuration, in the format:

  ```json
  {'unsubscribeGroups':[{'name':'group1','id':'xxxxx'},{'name':'group2','id':'xxxxx'},{'name':'group3','id':'xxxxx'}]}
```

Type: `string`

Default: `null`

### <a name="input_send_grid_user"></a> [send\_grid\_user](#input\_send\_grid\_user)

Description: The SendGrid user for custom SendGrid configuration

Type: `string`

Default: `null`

### <a name="input_sendgrid_events_site_key_rotation_increment"></a> [sendgrid\_events\_site\_key\_rotation\_increment](#input\_sendgrid\_events\_site\_key\_rotation\_increment)

Description:   Keep at 0 during initial registration; then monotonically increment by exactly one to rotate the site's SendGrid  
  event receiver site key. The previous key stays valid until the next rotation. Never decrease or reuse a prior value.  
  If it is reset to 0 by mistake the stored key reverts to the original registration key, which is no longer valid:  
  set any value of 1 or more to rotate again.

Type: `number`

Default: `0`

### <a name="input_service_plan_sku"></a> [service\_plan\_sku](#input\_service\_plan\_sku)

Description: The sku for the app service plan

Type: `string`

Default: `"P0v3"`

### <a name="input_sql_admin_login"></a> [sql\_admin\_login](#input\_sql\_admin\_login)

Description: The username for the SQL server admin login

Type: `string`

Default: `"superadmin"`

### <a name="input_sql_entra_login_only"></a> [sql\_entra\_login\_only](#input\_sql\_entra\_login\_only)

Description: Enforce Entra login only for the SQL server

Type: `bool`

Default: `true`

### <a name="input_sql_fw_rules"></a> [sql\_fw\_rules](#input\_sql\_fw\_rules)

Description:   Map of SQL firewall rule objects to create"

  ```terraform
  sql_fw_rules = {
    "Client1" = {
      start_ip_address = "1.2.3.4"
      end_ip_address   = "1.2.3.4"
    },
    "ClientRange2" = {
      start_ip_address = "1.2.4.10"
      end_ip_address   = "1.2.4.20"
    }
```

Type:

```hcl
map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
```

Default: `{}`

### <a name="input_sqldb_max_size_gb"></a> [sqldb\_max\_size\_gb](#input\_sqldb\_max\_size\_gb)

Description: The maximum size of the SQL database in GB

Type: `number`

Default: `2`

### <a name="input_sqldb_monthly_retention"></a> [sqldb\_monthly\_retention](#input\_sqldb\_monthly\_retention)

Description: The number of monthly backups to retain for the SQL database, must be in ISO 8601 format.

Type: `string`

Default: `"P6M"`

### <a name="input_sqldb_pitr_days"></a> [sqldb\_pitr\_days](#input\_sqldb\_pitr\_days)

Description: The number of days to retain Point In Time Restore backups for the SQL database

Type: `number`

Default: `14`

### <a name="input_sqldb_sku"></a> [sqldb\_sku](#input\_sqldb\_sku)

Description: The sku for the SQL database

Type: `string`

Default: `"S0"`

### <a name="input_syslog_token"></a> [syslog\_token](#input\_syslog\_token)

Description: Value for the Bunny syslog token

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description:   Key-value pairs of tags to apply to all resources in this site"

  ```terraform
  tags = {
    environment = "production"
    owner       = "team"
  }
```

Type: `map(string)`

Default: `{}`

### <a name="input_templates_folder_override"></a> [templates\_folder\_override](#input\_templates\_folder\_override)

Description:   Optional: The name of the templates folder to use for the site.  
  If not supplied will default to the site\_name.

Type: `string`

Default: `null`

### <a name="input_ubiq_captcha_admin_key_selection"></a> [ubiq\_captcha\_admin\_key\_selection](#input\_ubiq\_captcha\_admin\_key\_selection)

Description: Selection for the Ubiq captcha service admin key, should be either 'primary' or 'secondary'

Type: `string`

Default: `"primary"`

### <a name="input_ubiq_sendgrid_events_admin_key_selection"></a> [ubiq\_sendgrid\_events\_admin\_key\_selection](#input\_ubiq\_sendgrid\_events\_admin\_key\_selection)

Description: Selection for the Ubiq SendGrid event receiver admin key, should be either 'primary' or 'secondary'

Type: `string`

Default: `"primary"`

### <a name="input_ubiq_shortener_api_key_selection"></a> [ubiq\_shortener\_api\_key\_selection](#input\_ubiq\_shortener\_api\_key\_selection)

Description: Selection for the Ubiq shortener API key, should be either 'primary' or 'secondary'

Type: `string`

Default: `"primary"`

### <a name="input_veracross_account_name"></a> [veracross\_account\_name](#input\_veracross\_account\_name)

Description: The Veracross account name

Type: `string`

Default: `null`

### <a name="input_veracross_oauth_settings_client_id"></a> [veracross\_oauth\_settings\_client\_id](#input\_veracross\_oauth\_settings\_client\_id)

Description: The value for OAuthSettings\_\_ClientId

Type: `string`

Default: `null`

### <a name="input_veracross_oauth_settings_client_secret"></a> [veracross\_oauth\_settings\_client\_secret](#input\_veracross\_oauth\_settings\_client\_secret)

Description: The value for OAuthSettings\_\_ClientSecret

Type: `string`

Default: `null`

### <a name="input_veracross_oauth_settings_scope"></a> [veracross\_oauth\_settings\_scope](#input\_veracross\_oauth\_settings\_scope)

Description: The Veracross OAuth settings scope

Type: `string`

Default: `null`

### <a name="input_veracross_synch_job_schedule_cron_expression"></a> [veracross\_synch\_job\_schedule\_cron\_expression](#input\_veracross\_synch\_job\_schedule\_cron\_expression)

Description: The cron expression for the Veracross Synch Job Settings - Scheduler\_\_VeracrossSynchJob

Type: `string`

Default: `"0 0 4 * * ?"`

### <a name="input_waf_rules_disable_paths"></a> [waf\_rules\_disable\_paths](#input\_waf\_rules\_disable\_paths)

Description: A list of URL paths to disable Bunny WAF rules

Type: `list(string)`

Default: `[]`

### <a name="input_web_app_os"></a> [web\_app\_os](#input\_web\_app\_os)

Description: The operating system of the web app, either Windows or Linux

Type: `string`

Default: `"Windows"`

### <a name="input_web_app_x_azure_fdid_lockdown"></a> [web\_app\_x\_azure\_fdid\_lockdown](#input\_web\_app\_x\_azure\_fdid\_lockdown)

Description: If enabled, the web app will accept traffic only from the Bunny CDN/WAF and remote access subnets

Type: `bool`

Default: `true`

### <a name="input_web_domains"></a> [web\_domains](#input\_web\_domains)

Description: List of domain names to add to the web app

Type: `list(string)`

Default: `[]`

### <a name="input_weglot_redirection_enabled"></a> [weglot\_redirection\_enabled](#input\_weglot\_redirection\_enabled)

Description: Enable authentication redirection for Weglot

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### <a name="output_bunny_pullzone_id"></a> [bunny\_pullzone\_id](#output\_bunny\_pullzone\_id)

Description: n/a

### <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id)

Description: n/a

### <a name="output_ubiq_sso_entity_id"></a> [ubiq\_sso\_entity\_id](#output\_ubiq\_sso\_entity\_id)

Description: n/a

### <a name="output_ubiq_sso_redirect_urls"></a> [ubiq\_sso\_redirect\_urls](#output\_ubiq\_sso\_redirect\_urls)

Description: n/a

### <a name="output_ubiq_sso_urls"></a> [ubiq\_sso\_urls](#output\_ubiq\_sso\_urls)

Description: n/a

### <a name="output_website_prod_url"></a> [website\_prod\_url](#output\_website\_prod\_url)

Description: n/a

### <a name="output_website_staging_url"></a> [website\_staging\_url](#output\_website\_staging\_url)

Description: n/a

## Modules

The following Modules are called:

### <a name="module_avm-res-keyvault-vault"></a> [avm-res-keyvault-vault](#module\_avm-res-keyvault-vault)

Source: Azure/avm-res-keyvault-vault/azurerm

Version: ~>0.12.0

### <a name="module_avm-res-managedidentity-userassignedidentity-app"></a> [avm-res-managedidentity-userassignedidentity-app](#module\_avm-res-managedidentity-userassignedidentity-app)

Source: Azure/avm-res-managedidentity-userassignedidentity/azurerm

Version: ~>0.3

### <a name="module_avm-res-managedidentity-userassignedidentity-sql"></a> [avm-res-managedidentity-userassignedidentity-sql](#module\_avm-res-managedidentity-userassignedidentity-sql)

Source: Azure/avm-res-managedidentity-userassignedidentity/azurerm

Version: ~>0.3

### <a name="module_avm-res-managedidentity-userassignedidentity-sqldb"></a> [avm-res-managedidentity-userassignedidentity-sqldb](#module\_avm-res-managedidentity-userassignedidentity-sqldb)

Source: Azure/avm-res-managedidentity-userassignedidentity/azurerm

Version: ~>0.3

### <a name="module_avm-res-managedidentity-userassignedidentity-st"></a> [avm-res-managedidentity-userassignedidentity-st](#module\_avm-res-managedidentity-userassignedidentity-st)

Source: Azure/avm-res-managedidentity-userassignedidentity/azurerm

Version: ~>0.3

### <a name="module_avm-res-storage-storageaccount"></a> [avm-res-storage-storageaccount](#module\_avm-res-storage-storageaccount)

Source: Azure/avm-res-storage-storageaccount/azurerm

Version: ~>0.8.0

### <a name="module_bunny_cdn_waf"></a> [bunny\_cdn\_waf](#module\_bunny\_cdn\_waf)

Source: api.controlmonkey.io/o-26drsisx9g/cdn-waf/bunnynet

Version: ~>1.1

### <a name="module_clean_bunny_pullzone_config"></a> [clean\_bunny\_pullzone\_config](#module\_clean\_bunny\_pullzone\_config)

Source: ./modules/clean_object_null_values

Version:

### <a name="module_clean_bunny_pullzone_shield_config"></a> [clean\_bunny\_pullzone\_shield\_config](#module\_clean\_bunny\_pullzone\_shield\_config)

Source: ./modules/clean_object_null_values

Version:

### <a name="module_monitoring_diagnostics"></a> [monitoring\_diagnostics](#module\_monitoring\_diagnostics)

Source: api.controlmonkey.io/o-26drsisx9g/monitoring-diagnostics/azurerm

Version: ~>1.3

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/avm-utl-regions/azurerm

Version: ~>0.7.0

### <a name="module_short-region-lookup"></a> [short-region-lookup](#module\_short-region-lookup)

Source: api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm

Version: ~>1.0.0

### <a name="module_ubiq_resources"></a> [ubiq\_resources](#module\_ubiq\_resources)

Source: api.controlmonkey.io/o-26drsisx9g/ubiq-resources/azapi

Version: ~>1.0

# Additional Information

This module is created for use at Ubiq.
<!-- END_TF_DOCS -->