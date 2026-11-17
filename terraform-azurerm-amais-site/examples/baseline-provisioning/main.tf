module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.5.0"

  # ... required settings omitted for brevity ...

  ## Provision from the Baseline site
  # Start a NEW site from the Baseline site's content. The latest nightly snapshot of the Baseline database and blob
  # container is imported once, as-is, right after the SQL database is created and before the normal database release runs.
  # Set this in the same apply that creates the site. It fires whenever Terraform creates the database, including a
  # replacement, so do not turn it on for an existing site unless Baseline content is wanted when its database is next
  # re-created. The pipeline records a one-off completion marker in the site's storage account (container "provisioning",
  # blob "baseline-provision.json"): once a run has completed, later runs are no-ops, so content is never copied twice and
  # assets deleted later are never restored. Turning it off changes nothing.
  provision_from_baseline = true # OPTIONAL - Default is false
}
