# WKFLO Container Apps

This Terraform stack deploys a single WKFLO workload into an existing WKFLO Container Apps Environment (CAE). It is intentionally app-scoped rather than environment-scoped: the shared platform resources already exist, and this stack attaches one containerized application to them.

Use this stack when you want to deploy or update an app such as `ca-wkflo-alloy` or `ca-wkflo-backend-ai` in an existing `staging` or `prod` WKFLO environment.

## What This Stack Creates

For each app deployment, this stack creates or manages:

- One Azure Container App, via the shared `terraform-azurerm-cae-app` module.
- One app-specific user assigned managed identity named `id-<app>-<environment>` in the WKFLO global resource group.
- Optional role assignments for that managed identity so the app can read central Key Vault secrets, use central Key Vault keys, or call Azure AI services.
- Optional app secrets and mounted configuration for Grafana Alloy deployments.

This stack does not create the Container Apps Environment itself, the per-region app resource groups, the per-region Key Vaults, or the shared platform services. Those are inputs from other stacks.

## How The Deployment Works

At a high level, the flow is:

1. `apps/<env>/<app>.tfvars` defines the workload-specific settings such as the app name, image, ingress, probes, scale rules, and feature flags.
2. Control Monkey injects the environment-level values that come from the WKFLO environment stack, plus mutable values such as CPU, memory, replicas, and image tag.
3. `locals.tf` derives the final names and selects the correct regional resources for `var.azure_long_region`.
4. `main.tf` deploys the container app into the existing regional WKFLO CAE and binds it to the shared ACR pull identity and the app-specific identity.
5. `identity_roles.tf` grants optional access to central/shared resources based on feature flags in the `.tfvars` file.

The stack uses an AzureRM backend configured in `terraform.tf`, but the backend `key` is intentionally left blank and must be supplied from the deployment-specific `.tfbackend` file.

## Local Files In This Stack

The key files are:

- `main.tf`: instantiates the reusable container app module and passes ingress, scaling, secrets, identity, and registry settings.
- `locals.tf`: builds standard names, tags, and selects the correct regional resources from environment stack outputs.
- `data_sources.tf`: looks up central/shared resources such as the central Key Vault and shared Log Analytics workspace.
- `identity_roles.tf`: creates the app managed identity and grants optional RBAC roles.
- `container_env_vars.tf`: injects extra environment variables required for Grafana Alloy / Tempo.
- `grafana_alloy.tf`: creates the inline Alloy configuration secret when `add_grafana_alloy_env_vars = true`.
- `apps/staging` and `apps/prod`: contain the app-specific `.tfvars` and `.tfbackend` examples.

## Environment And Shared Resource Dependencies

This stack relies on two categories of external resources.

### 1. WKFLO Environment Resources

These come from the `tf/wkflo-environment` stack and are passed in as Terraform variables or Control Monkey stack variables:

- `cae`: the target Container Apps Environment per region.
  Used by this stack to place the app into the correct CAE and to obtain the CAE default domain.
- `cae_app_resource_group_names`: the per-region app resource groups.
  Used to decide where the container app resource is created.
- `cae_key_vault_resources`: the per-region Key Vaults attached to the WKFLO environment.
  Used so the container app module can store app-local secrets in the correct regional Key Vault.
- `cae_law_resources`: the per-region Log Analytics workspaces.
  Used by the container app module for diagnostics and platform integration.
- `cae_identities`: the per-region user assigned identities for the CAE environment.
  Attached as additional identities when available.
- `cae_arcpull_identity`: the global ACR pull identity.
  Used by the container app to pull images from Azure Container Registry.
- `cae_global_resource_group_name`: the shared WKFLO global resource group.
  Used as the location for the app-specific managed identity.
- `cae_mssql_resources`: the per-region Azure SQL resourcse for the CAE environment.
- `cae_postgresql_resources`: the per-region Azure Postgresql flexible server resources for the CAE environment.

In practice, this means `wkflo-container-apps` should be applied only after the `wkflo-environment` stack for the target environment already exists and its outputs are available to Control Monkey.

### 2. Central / Shared Resources

These are looked up directly inside this stack and are reused by multiple deployments:

- Central Key Vault: `kv-uks-amais-central` in `rg-uks-amais-central`.
  Used for shared secrets and keys that some apps need. If `central_key_vault_secret_access_enabled = true`, the app identity gets `Key Vault Secrets User`. If `central_key_vault_key_access_enabled = true`, it gets `Key Vault Crypto User`.
- Shared Log Analytics workspace: `log-uks-ubiq-shared-logging` in `rg-uks-ubiq-shared-logging`.
  Currently looked up as a shared monitoring dependency. The container app module itself is fed the regional CAE Log Analytics workspace, not this shared workspace.
- Azure AI subscriptions whose display name starts with `UBIQAI`.
  When `azure_ai_model_access_enabled = true`, the app identity is granted `Azure AI User`, `Cognitive Services OpenAI User`, and `Cognitive Services Speech User` across those subscriptions.
- Grafana Cloud Tempo and API secrets in the central Key Vault.
  When `add_grafana_alloy_env_vars = true`, the stack injects the required Tempo endpoint and secret references and mounts an Alloy config file into the container.

## App Configuration Model

Each app is defined by a pair of files:

- `<app>.tfvars`: workload configuration.
- `<app>.tfbackend`: Terraform state key for that workload and environment.

Example:

- `apps/staging/ca-wkflo-alloy.tfvars`
- `apps/staging/ca-wkflo-alloy.tfbackend`

The `.tfvars` file should contain values that are stable for that app in that environment, for example:

- `environment`
- `azure_long_region`
- `name`
- `image_name`
- `ingress` (optional)
- probes (optional, see `variables.tf` for details)
- scaling rules (optional, see `variables.tf` for details)
- feature flags such as central Key Vault access or Grafana Alloy support
- app-specific environment variables (optional, `additional_env_vars`)

The `.tfbackend` file should contain only the Terraform state key, for example:

```hcl
key = "wkflo-container-apps/ca-wkflo-alloy/staging.tfstate"
```

Use a unique backend key per app and per environment.

## Creating A New Staging Or Production App

To add a new workload, follow this process:

1. Copy the closest existing `.tfvars` file under `apps/staging` or `apps/prod`.
2. Rename it to match the app, for example `ca-wkflo-myapp.tfvars`.
3. Set the stable app configuration:
   - `environment`: use the target environment value used by the platform, for example `staging` or `prod`.
   - `azure_long_region`: currently examples use `uksouth`.
   - `name`: the base container app name. The stack builds the deployed name as `<name>-<environment>`.
   - `image_name`: full image reference without the tag.
   - ingress, probes, scale rules - see `variables.tf` for options and syntax.
   - `additional_env_vars` for non-secret app-specific environment variables.
4. Create the matching `.tfbackend` file in the same folder.
5. Set the backend `key` to a unique state path for the app and environment, for example `wkflo-container-apps/ca-wkflo-myapp/staging.tfstate`.
6. In Control Monkey:
   1. Create a stack in the [wkflo namespace](https://console.controlmonkey.io/app/namespace/ns-p708ekvjxb). You can use an existing app stack for reference.
   2. Set the correct tfvars file on the stack.
   3. Set the correct terraform backend file by adding the `TF_CLI_ARGS_init` environment variable (not terraform variable), see below.
   4. Populate the required environment-level inputs in the dependencies section of the Control Monkey stack from the `wkflo-environment` outputs. You can use an existing app stack for reference.
   5. Populate the mutable per-release values in the Control Monkey stack, especially `image_tag`.

If the app needs shared secrets, shared cryptographic keys, Grafana Alloy config, or Azure AI access, enable the relevant booleans in the `.tfvars` file so the role assignments and secret wiring are created automatically.

## Control Monkey Stack Variables

The app examples already note that some values are intentionally supplied by the Control Monkey stack rather than committed to the `.tfvars` file. This allows for easier operational changes without code changes - e.g. updating the tag version or increasing the cpu.

### Backend Configuration

Set the init arguments so Terraform uses the correct backend config file for the app/environment pair.

Example:

```text
TF_CLI_ARGS_init = -backend-config="./apps/staging/ca-wkflo-alloy.tfbackend"
```

For a production deployment, point to the production backend file instead.

### Variable File Selection

Set the tfvar file in the Control Monkey stack configuration: General > Advanced > Var Files. The path is relative to the stack root, e.g. `./apps/staging/ca-wkflo-alloy.tfvars`.

### Values Commonly Supplied By Control Monkey

These values are expected to vary per deployment or to come from another stack, so they are good candidates for Control Monkey stack variables:

- `cpu`
- `memory`
- `image_tag`
- `min_replicas`
- `max_replicas`
- `cae`
- `cae_identities`
- `cae_key_vault_resources`
- `cae_law_resources`
- `cae_global_resource_group_name`
- `cae_arcpull_identity`
- `cae_app_resource_group_names`

The last seven items should normally be sourced from the `wkflo-environment` stack outputs for the matching environment using stack dependencies.

## Operational Notes

- The deployed container app name is derived as `<lower(name)>-<lower(environment)>`.
- If no scale rules are supplied, the stack adds a default HTTP scale rule with `concurrent_requests = 10`.
- For Grafana Alloy deployments, the stack mounts `/etc/alloy/config.alloy` from a secret and injects Tempo credentials from the central Key Vault.

## Recommended Workflow For New Engineers

When troubleshooting or adding an app, work in this order:

1. Confirm the target WKFLO environment already exists and the `wkflo-environment` stack outputs are available.
2. Create or update the app's `.tfvars` file.
3. Create or update the matching `.tfbackend` file.
4. Create the Control Monkey stack and set the environment variable `TF_CLI_ARGS_init` and the required per deployment terraform variables.
5. Verify the environment stack outputs are mapped into the required variables for this stack using dependencies.

That sequence keeps the app deployment isolated while still reusing the central and environment-level platform resources correctly.
