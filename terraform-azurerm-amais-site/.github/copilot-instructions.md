# GitHub Copilot Instructions for terraform-azurerm-amais-site

## Purpose and Scope

This repository is a Terraform module that provisions complete infrastructure for an AMAIS site in Azure. It includes:

- App Service (Windows or Linux)
- App Service Plan and staging slot behavior
- SQL Server and SQL Database with encryption and auditing controls
- Storage Account, containers, static website files, and lifecycle policy
- Key Vault and secret/key wiring
- CDN/WAF behavior (Bunny and Azure CDN migration modes)
- DNS records
- Optional feature integrations (AI chatbot, payments, directory and SSO providers, workflows, SendGrid, DXP)
- Registration with Ubiq platform services (Cap captcha, SendGrid event receiver) through `restful_operation`

When generating or editing code in this repository, preserve module stability and avoid introducing breaking behavior in conditional resource graphs.

## Instructions Maintenance

- Treat this file as a living source of truth for this repository.
- When new facts are learned while working in this codebase (conventions, Azure resource limitations and workarounds, etc), update this file in the same task whenever practical.
- Prefer concise, high-signal updates over long prose.
- If a learned fact is uncertain, mark it explicitly as an assumption and verify it before treating it as a rule.
- When a prior instruction becomes outdated, replace it rather than appending contradictory guidance.

## Repository Layout

Top-level files are organized by concern:

- `main.tf`: foundational module setup, resource group, core waits, core key resources
- `provider.tf`: provider configuration and aliases (`azurerm`, `azurerm.shared`, `azuread.amais`, `restful.*`)
- `terraform.tf`: required version and providers
- `actions.tf`: azureactions pipeline-trigger actions, fired by `action_trigger` blocks on the SQL DB (`deploy_sql_dacpac`, `provision_from_baseline`), the Linux/Windows staging web app slots (`deploy_amais`, on `azurerm_linux_web_app_slot.main_staging` / `azurerm_windows_web_app_slot.main_staging`) and `terraform_data.web_domains` (`configure_dxp`, `after_update`), and `azurerm_storage_table_entity.amais_site` (`onboard_client_assets`, `after_create`)
- `variables.tf`: all input variables and validation rules
- `locals.tf`: computed naming, environment maps, feature gate derivations, connection strings
- `data_sources.tf`: shared/subscription and tenant lookups
- `web_app_common.tf`: shared app-service-related constructs
- `web_app_linux.tf`: Linux web app and slot resources
- `web_app_windows.tf`: Windows web app and slot resources
- `web_app_settings.tf`: app settings and sticky settings composition
- `sql.tf`: SQL Server, SQL DB, firewall and SQL-related dependencies
- `storage.tf`: storage account and container behavior
- `key_vault.tf`: key vault and secret/key configuration
- `bunny.tf`, `cdn.tf`, `dns.tf`: CDN/WAF/DNS path and migration behavior
- `monitoring.tf`: diagnostics and alerts
- `event_grid.tf`: event-grid based automation
- `ubiq_sso.tf`: Entra SSO app and role assignment resources
- `chatbot_config_blob.tf`, `config_blob.tf`, `platform_config.tf`: config data artifacts and metadata wiring
- `captcha.tf`: Cap captcha service site registration (every site)
- `sendgrid_events.tf`: SendGrid event receiver site registration (slots with custom SendGrid config only)
- `moved.tf`: state migration mappings for historical refactors
- `outputs.tf`: module outputs
- `examples/`: contains scenario-driven sample usage. Reuse patterns from examples when adding new feature toggles.

## Core Conventions

### Naming

- Core names are derived from `local.formatted_name = "${local.short_region}-${local.lower_site_name}"`.
- Common prefixes:
  - `rg-` resource groups
  - `asp-` app service plans
  - `app-` web apps
  - `sql-` sql servers
  - `sqldb-` sql databases
  - `id-` managed identities
- Storage accounts are randomized to satisfy global uniqueness and naming limits.
- Key vault naming respects Azure name-length constraints via local truncation/suffix logic.
- Otherwise always follow abbreviation conventions for Azure resources from the Microsoft documentation here: <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations>

### Tagging

- Always preserve tag merge pattern:
  - `merge(var.tags, local.common_tags)`
- Where applicable, include data classification overlays (`public` vs `confidential`) consistently.

### Providers and Aliases

- `azurerm` (default) deploys into target subscription (`var.sub_id`).
- `azurerm.shared` is used for shared central resources and cross-subscription lookups.
- `azuread.amais` is used for AMAIS tenant operations.
- `restful.bunny_shield` drives the Bunny Shield API; `restful.captcha_prod`/`captcha_staging` and `restful.sendgrid_events_prod`/`sendgrid_events_staging` call the Ubiq services' admin APIs (one alias per environment, because providers cannot `for_each`).
- Do not remove provider alias usage from data sources that intentionally target shared resources.

### Conditional Resources and Feature Gates

- The module relies heavily on `count` and `for_each` for optional behavior.
- Keep conditions centralized in locals when possible.
- Use `for_each` for map-like user objects that must be stable across edits (for example firewall rules).
- For optional nested blocks, use dynamic-block patterns that emit zero or one block as needed.

### OS-Split Web App Pattern

- Linux and Windows app resources are split into separate files and conditionally created.
- Keep OS-specific references guarded by `var.web_app_os` or an equivalent local selector.
- When adding parallel resources in both OS files, ensure Terraform resource names are unique per type in the module.

### Dependency Sequencing

- This module intentionally uses `time_sleep` to absorb eventual consistency and propagation delays (RBAC, key vault readiness, SQL readiness, DNS timing).
- Do not remove waits unless a replacement has been validated against real Azure timing behavior.
- If adding a new dependency-sensitive resource, explicitly wire `depends_on` and, where needed, a wait trigger.

### Secret and Credential Handling

- Do not hardcode secrets.
- Prefer key vault data sources and secret-name indirection through locals.
- Keep sensitive variables marked as sensitive.
- Maintain managed identity and Entra-based auth patterns for SQL connection strings.
- Ubiq service admin keys (`cap-<env>-admin-key-*`, `sgevents-<env>-admin-key-*` in `kv-uks-ubiq-shared-res`) are used only in the `restful` provider `security` blocks. Never put them in a resource header, the site Key Vault, app settings, config blobs or outputs.
- Ubiq service site keys go only to the site Key Vault (through the `kv_*_sk`/`kv_*_sv` maps) and reach the web app only as `@Microsoft.KeyVault(...)` references. Never expose them as an output (not even `sensitive`), a literal setting, a config blob, a tag or a log line.

### CDN and Migration Behavior

- `bunny_cdn_enablement` controls migration and provider behavior.
- Keep condition expressions consistent between Bunny, Azure CDN, and DNS resources.
- Avoid introducing cyclical references between web app origins, CDN endpoints, and DNS records.

### Ubiq Service Registrations (captcha, SendGrid event receiver)

- `captcha.tf` and `sendgrid_events.tf` are identical in `terraform-azurerm-amais-site` and `terraform-azurerm-amais-site-legacy`; change and release both modules in lock step.
- Contracts: `infra-shared` `tf/ubiq-cap-core-bunny/API.md` ("Provisioning from Terraform", including the recovery runbook) and `tf/ubiq-sendgrid-event-receiver/API.md` / `SENDGRID.md`.
- Registered site names are separate 8-byte `random_id` values. Never use the web app's name or the internal site name, or anything derived from either.
- The register operation's body is only `siteName`; captcha origins go in their own operation, sorted and de-duplicated. Changing either body re-runs that operation.
- `restful_operation` never reads remote state, so a registration deleted outside Terraform is invisible to plan; follow the captcha API.md runbook rather than `-replace` on the register operation alone.
- Key rotation is driven by `captcha_site_key_rotation_increment` / `sendgrid_events_site_key_rotation_increment`: increment by exactly one, never decrease. This is a convention only, with no state guard (a `prevent_destroy` guard was tried and removed because it blocks site teardown). If a counter is reset to 0 by mistake, set any value of 1 or more to rotate again.
- The two Ubiq admin-key data sources (`ubiq_captcha_admin_key`, `ubiq_sendgrid_events_admin_key`) always read both `prod` and `staging`. Do not gate them by `captcha_environments` / `sendgrid_events_environments`: the gated lookup vanishes in the plan that destroys the registration, and the provider's `try(...)` then sends the DELETE without a key.
- Captcha environments match `shortener_environments` (no toggle); every site plan reads `https://<captcha host>/assets/manifest.json`. SendGrid receiver environments follow the `enable_custom_send_grid_config_*` flags per slot.

### Provisioning from the Baseline Site (`provision_from_baseline`)

- Opt-in (default `false`). Copies the Baseline site's nightly BACPAC, blobs and static website (`$web`) content into a NEW site, using the `provision_from_baseline` action in `actions.tf` (Azure DevOps project `PetraCMS`). Its pipeline ID is 157 (`AMAIS_DB\Provision from Baseline`, set directly in the action like `deploy_sql_dacpac`'s 108). A `validation` on the variable also rejects the flag for the site whose key (templates folder) is `Baseline`.
- The flag fires whenever Terraform creates the DB (`after_create`), including a replacement of an existing DB. Once a run has completed, the marker makes later runs no-ops; do not turn it on for an existing site unless Baseline content is wanted when its DB is next re-created. Sites with the flag off see no action or DB change, but every site gets a one-time additive in-place update of its AMAISSites entity (`storage_account_name`, `storage_container_name`) on its first 2.5.0 apply. Apply that outside release/swap windows: the entity write (InsertOrMerge, with the `ignore_changes` lock fields taken from refresh) can put back stale lock values. The DB `depends_on` `azurerm_storage_table_entity.amais_site` (which references the storage account and main container outputs), `azurerm_mssql_firewall_rule.main_secure_access_gw` and `azurerm_storage_blob.static_files` because the pipeline reads the site's details (SQL server, database, storage account and container) from its AMAISSites entity, reads the marker, reaches SQL from the DevOps agent pool through the hub NAT gateway IPs those firewall rules allow (no temporary firewall rule), and copies the Baseline's `$web` content into the site's `$web`. `$web` only exists once `azurerm_storage_account_static_website.main` has enabled the static website (`static_files` depends on it), and the module's own `$web` files must be uploaded first: the pipeline copies with no overwrite, and `azurerm_storage_blob` cannot create a blob that already exists. The pipeline stops before changing anything if `$web` is missing. If the action fails after the DB exists, a later apply does not retry it: re-run the pipeline manually (a completed run is a no-op because of the marker; if the DB import finished but a later step failed, set `skipDatabaseImport=true`; see the `AMAIS_DB` `pipelines/provision_from_baseline.md` runbook), then `deploy_sql_dacpac`.
- `azurerm_mssql_database.main` has ONE `action_trigger` with no `condition`: `[provision_from_baseline, deploy_sql_dacpac]`, run in that order (a trigger's `actions` run in list order; the first action uses `wait_for_completion = true` with a 120 minute timeout). The flag is applied as `enabled = var.provision_from_baseline` in the `provision_from_baseline` action's config (azureactions 1.3.0, pinned `~>1.3`): disabled, the invocation does nothing (no token request, no pipeline run). Never put the flag (or any variable or local) in an `action_trigger` `condition`: from Terraform 1.16 a destroy plan evaluates the conditions of `after_create` triggers without the variables and locals they refer to, so every destroy fails with "Reference to uninitialized variable" (a Terraform bug, still in 1.17.1). A destroy plan does not evaluate action configuration. From azureactions 1.2.0 the provider gets a fresh token for every status poll and retries transient errors (network errors, 408, 429, 5xx, honouring `Retry-After`) until the 120 minutes are up. It stops early only on a definitive Entra ID rejection, 5 failed token requests in a row, or a fatal Azure DevOps response (400/403/404 or a 401 after re-requesting the token), and the error then says the run was not cancelled and may still be running. In that case `deploy_sql_dacpac` is not queued: let the pipeline finish and run the DB release (pipeline 108) for the site by hand, as the AMAIS_DB runbook describes. The wait starts when the run is queued, while the pipeline job's own 90 minute timeout starts when an agent picks it up. With the flag off the plan still lists the `provision_from_baseline` invocation, which does nothing. `enabled` must be known when the action runs, so never base it on a resource attribute.
- The action sends only `site = local.templates_folder` (like `deploy_sql_dacpac`'s `includeSites`). The pipeline finds the AMAISSites entity with `RowKey = lower(site)` and reads `sql_fqdn`, `sqldb_name`, `storage_account_name` and `storage_container_name` (all written in `platform_config.tf`). Action config must use plan-known values only, so never pass resource attributes such as the random storage account name.
- `azurerm_storage_table_entity.amais_site` has a precondition backed by `data.azurerm_storage_table_entities.amais_site_key_in_use`: the plan fails if another subscription's row in AMAISSites already uses this site's RowKey (`lower(local.templates_folder)`), because automation treats the RowKey as the site's identity. New-AMAISSiteConfig.ps1 prevents duplicates for generated configs; this catches hand-written ones. The data source does not follow continuation tokens, so it can miss a duplicate (fails open). Do not add `select` to it.
- One-off marker: blob `baseline-provision.json` in container `provisioning` of the site storage account. The pipeline creates that container and Terraform must NOT manage it (changing the flag must never delete the marker; it also keeps the CMS media library clean). Never add it to `containers`.
- Terraform 1.14 orders an action only after its own resource and after earlier actions of that resource. Resources that depend on the DB (the web apps and their staging slots) do NOT wait for the DB's `after_create` actions, so `deploy_amais` can start while the import runs. There is no Terraform-level fix.

### Client Assets Onboarding (`onboard_client_assets`)

- `onboard_client_assets` (default `true`) gates the action together with a configured pipeline ID (`actions.tf`, Azure DevOps project `Client Assets`). `wait_for_completion` defaults to `false`: pipeline failures after a run is queued do not fail the site's apply, but authentication or queueing failures can. It sends only `siteName = var.site_name`, which is also the site's asset repository name. When enabled, it is fired by the `after_create` `action_trigger` (no `condition`) on `azurerm_storage_table_entity.amais_site`, once per new site (and on a site-key replacement), never on update.
- The pipeline ID is `local.client_assets_onboarding_pipeline_id` in `actions.tf`, currently 159. `pipeline_id` is required and must be > 0 even when disabled (azureactions 1.3.0), so the action uses `coalesce(id, 1)` and is disabled if the ID is ever set to `null`. Change the ID there, not through a variable.
- `captcha.tf`, `sendgrid_events.tf` and this action are kept identical in `terraform-azurerm-amais-site` and `terraform-azurerm-amais-site-legacy`.

### Regex and Terraform Compatibility

- Terraform regex uses RE2. Do not use lookaheads/lookbehinds.
- Write validation patterns with anchors and explicit classes only.

## Safe Editing Rules for Copilot

When editing this module:

1. Prefer minimal diffs and preserve existing graph semantics.
2. Do not rename resources unless also adding the correct `moved` block.
3. Do not replace `for_each` with `count` for user-supplied map entities.
4. Keep production/staging parity unless the feature explicitly differs by environment.
5. Preserve `merge(local_defaults, var_overrides)` precedence in app settings.
6. Respect lifecycle and ignore-change blocks used to suppress known Azure drift points.
7. Keep cross-subscription lookups bound to `azurerm.shared` where already established.
8. Do not introduce new hardcoded IDs where locals/data sources are already the project convention.

## How to Add New Features

Follow this workflow:

1. Add variables in `variables.tf` with type, sensible default, and validation.
2. Add derived locals in `locals.tf` for naming and enablement conditions.
3. Add data sources only if required, with correct provider alias.
4. Add resources in the most specific file for that concern.
5. Ensure optional resources are behind a feature toggle.
6. Add outputs only when they are broadly useful to module consumers.
7. If refactoring existing addresses, add/update `moved.tf`.
8. Add or update an `examples/` scenario when behavior is externally consumed.

## Validation and Regression Checks

Before finalizing changes, run:

- `terraform fmt -recursive`
- `terraform validate`

If there are linting or validation errors:

- Ensure the locally cached provider versions are up to date with `terraform init -upgrade` as a first step to fixing them.

When changing feature-gated resources, verify all relevant branches:

- Linux and Windows paths
- staging enabled and disabled
- Bunny modes (`no`, `prepare`, `migrate`, `yes`)
- optional integrations enabled and disabled

Check specifically for:

- resource address stability
- unintended destroy/recreate from key name or `for_each` key changes
- cross-subscription data reads still resolving in `azurerm.shared`
- no regex expressions that rely on unsupported RE2 features

## Common Pitfalls to Avoid

- Creating duplicate resource names across Linux and Windows variants.
- Breaking app settings precedence by reversing `merge` order.
- Removing waits that hide eventual-consistency issues.
- Introducing dependency cycles in CDN/web origin wiring.
- Changing naming logic that affects persistent resources without migration planning.
- You don't have a Bunny API key, if you need to validate API responses, ask the user to run the query and share the output. The query provided to run should be in PowerShell or Bash.

## Notes for AI Assistance in This Repo

- Prefer extending existing patterns over introducing new abstractions.
- Keep local maps and feature toggles explicit rather than clever.
- Favor readability and deterministic behavior over compact expressions.
- If uncertain, inspect matching patterns in sibling files before adding new logic.
- `README.md` is generated by terraform-docs from a git pre-commit hook on every commit (from `_header.md`, `_footer.md` and the variable and output descriptions). Never edit it by hand. In code reviews, do not flag `README.md` changes as manual edits or suggest running terraform-docs: a `README.md` diff in a pull request is always the hook's output, and the hook is not visible in the pull request. Review the sources instead.
- Spell check any comments.

## Authoritative References

Always validate syntax and behavior against the official provider documentation:

- azurerm provider documentation: <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs>
- azuread provider documentation: <https://registry.terraform.io/providers/hashicorp/azuread/latest/docs>
- azapi provider documentation: <https://registry.terraform.io/providers/azure/azapi/latest/docs>
- bunny provider documentation: <https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs>
- restful provider documentation (used for Bunny Shield bot-categorization, which bunnynet doesn't support, and Ubiq service registrations): <https://github.com/magodo/terraform-provider-restful>

## terraform-code-generation Skills

Skills for generating and validating Terraform HCL code:

| Skill                     | Description                                                                          |
| ------------------------- | ------------------------------------------------------------------------------------ |
| `terraform-style-guide`   | Generate Terraform HCL code following HashiCorp style conventions and best practices |
| `terraform-test`          | Writing and running `.tftest.hcl` test files                                         |
| `azure-verified-modules`  | Azure Verified Modules (AVM) requirements and certification                          |
| `terraform-search-import` | Discover existing resources with Terraform Search and bulk import into state         |

## When to Use Each Skill

Use when:

- Writing new Terraform configurations
- Reviewing Terraform code for style compliance
- Creating test files for Terraform modules
- Generating HCL for specific providers

## Azure DevOps CLI (az boards) Notes

This project's work items live in `https://dev.azure.com/PetraCMS/PetraCMS`. Use the `azure-devops` CLI extension (already installed) rather than guessing at REST calls.

- Confirm exact area/iteration path strings before creating a work item - do not assume the format:
  - `az boards area project list --project PetraCMS --organization https://dev.azure.com/PetraCMS -o json` - area paths are returned WITHOUT the leading `PetraCMS\` segment when passed to `--area` (e.g. use `"PetraCMS\DevOps"` even though this matches the full `path` field).
  - `az boards iteration project list --project PetraCMS --organization https://dev.azure.com/PetraCMS -o json` - the bare project name (e.g. `"PetraCMS"`) is a valid `--iteration` value and resolves to the root/default iteration (not a specific sprint).
  - `az boards work-item create --type "User Story" ...` - confirmed valid work item type for this process (not "Product Backlog Item").
- **User Story field mapping - do not put everything in Description**:
  - Acceptance criteria has its own dedicated field, `Microsoft.VSTS.Common.AcceptanceCriteria` (HTML, same as Description) - do not fold an "Acceptance Criteria" section into `System.Description`/`-d`. Set it separately via `--fields "Microsoft.VSTS.Common.AcceptanceCriteria=$flatAC"` (same flattening/quoting rules as description apply - see below).
  - `System.Description` should stay to background/context/scope-of-work only.
- **Windows/PowerShell + `az.cmd` argument-passing pitfalls when creating/updating work items with `-d/--description`** (both bit us creating story #7112, and produced a blank story #7111 that had to be deleted):
  - A multi-line string passed via `-d $variable` gets silently truncated to only its first line - no error is raised. Always flatten the description to a single line first: `$flat = $desc -replace '\r?\n', ' '`.
  - A literal, unescaped double-quote (`"`) character anywhere inside the description value breaks argument parsing (`az.cmd` re-tokenizes through `cmd.exe`), causing `unrecognized arguments: ...` errors partway through the string. Replace literal `"` with `'` (or HTML-encode as `&quot;`) before passing.
  - Always pass the flattened variable in double quotes to the CLI invocation itself (`-d "$flat"`), otherwise PowerShell splits it on spaces into multiple unrecognized arguments.
  - Recommended safe workflow: build description as HTML (multiline for readability), then immediately before use: `$flat = ($desc -replace '\r?\n', ' ') -replace '"', "'"`, then `az boards work-item create ... -d "$flat"`.
  - `--fields "FieldName=$value"` works fine for setting additional fields (e.g. acceptance criteria) as long as `$value` is quoted (`"$value"`) and pre-flattened to a single line - same rule as `-d`.
  - Sanity-check with `az boards work-item create --title "TEST-DELETE-ME" ...` first when trying new area/iteration/type combinations, then `az boards work-item delete --id <id> --project PetraCMS --organization ... --yes` to clean up (note: `--project` is required for delete even though `create` can infer it).
