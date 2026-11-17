<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-ubiq-resources

Module to query the central and shared Ubiq resources for consumption by other configurations and modules.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~>1.9)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~>2.10)

- <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) (~>3.0)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (2.10.0)

- <a name="provider_azuread"></a> [azuread](#provider\_azuread) (3.8.0)

## Resources

The following resources are used by this module:

- [azapi_resource.eventhub_namespace_pum_prod](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource) (data source)
- [azapi_resource.eventhub_namespace_pum_staging](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource) (data source)
- [azapi_resource_list.secure_access_gw_pips](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource_list) (data source)
- [azapi_resource_list.vnets](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource_list) (data source)
- [azuread_application.pum_api_prod](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application) (data source)
- [azuread_application.pum_api_staging](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application) (data source)
- [http_http.google_user_triggered_fetchers](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_get_google_bot_ips"></a> [get_google_bot_ips](#input_get_google_bot_ips)

Description: Lookup Google user-triggered fetcher IP ranges

Type: `bool`

Default: `false`

### <a name="input_get_pum"></a> [get\_pum](#input\_get\_pum)

Description: Lookup PUM API details

Type: `bool`

Default: `false`

### <a name="input_get_securegw_pips"></a> [get\_securegw\_pips](#input\_get\_securegw\_pips)

Description: Lookup NAT Secure Gateway Public IPs

Type: `bool`

Default: `false`

### <a name="input_get_vnets"></a> [get\_vnets](#input\_get\_vnets)

Description: Lookup all the virtual networks

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### <a name="output_all_vnets"></a> [all\_vnets](#output\_all\_vnets)

Description: n/a

### <a name="output_devops_subnets"></a> [devops\_subnets](#output\_devops\_subnets)

Description: n/a

### <a name="output_hub_vnets"></a> [hub\_vnets](#output\_hub\_vnets)

Description: n/a

### <a name="output_pum"></a> [pum](#output\_pum)

Description: n/a

### <a name="output_secure_access_gw_pips"></a> [secure\_access\_gw\_pips](#output\_secure\_access\_gw\_pips)

Description: n/a

### <a name="output_terraform_subnets"></a> [terraform\_subnets](#output\_terraform\_subnets)

Description: n/a

### <a name="output_twingate_subnets"></a> [twingate\_subnets](#output\_twingate\_subnets)

Description: n/a

## Modules

No modules.

# Additional Information

This module is created for use at Ubiq.
<!-- END_TF_DOCS -->