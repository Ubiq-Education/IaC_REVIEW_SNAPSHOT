action "azureactions_devops_pipeline_trigger" "deploy_sql_dacpac" {
  config {
    project     = "PetraCMS"
    pipeline_id = 108
    auth_method = "default_azure_credential"

    template_parameters = {
      includeSites = local.templates_folder
    }
  }
}

# One-off copy of the Baseline site's content (database, blobs and static website) into a newly created site. Invoked
# by the database's after_create action trigger in sql.tf, ahead of deploy_sql_dacpac, and does nothing unless
# var.provision_from_baseline is true (enabled).
# Like deploy_sql_dacpac's includeSites, the pipeline gets only the site key - the site's AMAISSites row key (its
# templates folder for sites created by this module) - and reads everything else (SQL server, database, storage
# account, container) from that entity (platform_config.tf, RowKey = lower(local.templates_folder)).
action "azureactions_devops_pipeline_trigger" "provision_from_baseline" {
  config {
    project             = "PetraCMS"
    pipeline_id         = 157 # AMAIS_DB \ Provision from Baseline
    auth_method         = "default_azure_credential"
    wait_for_completion = true # The restore must finish before deploy_sql_dacpac starts
    # Counts from when the run is queued. From azureactions 1.2.0 the provider gets a fresh token for each poll and
    # retries transient errors; it stops early only on a definitive credential rejection, 5 failed token requests in a
    # row or a fatal Azure DevOps response, and then says the run may still be running (see the AMAIS_DB runbook).
    timeout_minutes = 120
    # azureactions 1.3.0: false makes the invocation a no-op (no token request, no pipeline run)
    enabled = var.provision_from_baseline

    template_parameters = {
      site = local.templates_folder
      # snapshotId (default "latest") and skipDatabaseImport (default "false") are left to the pipeline defaults
    }
  }
}

action "azureactions_devops_pipeline_trigger" "deploy_amais" {
  config {
    branch_ref  = "refs/tags/latest"
    project     = "PetraCMS"
    pipeline_id = 114
    auth_method = "default_azure_credential"

    template_parameters = {
      region       = var.az_long_region
      deployToProd = "true"
      siteToDeploy = local.templates_folder
    }
  }
}

action "azureactions_devops_pipeline_trigger" "configure_dxp" {
  config {
    project     = "PetraCMS"
    pipeline_id = 23
    auth_method = "default_azure_credential"

    template_parameters = {
      SiteNames    = jsonencode([local.templates_folder])
      Environments = jsonencode(["staging", "production"])
    }
  }
}

# The Client Assets onboarding pipeline is created by infra-shared.
locals {
  client_assets_onboarding_pipeline_id = 159
}

# Onboards a newly created site to Client Assets: the pipeline creates the site's asset repository (named after the
# site) and its pipelines and branch policies in the Client Assets project. Invoked by the AMAISSites entity's
# after_create action trigger in platform_config.tf, so it runs once, when the site is created, and never on update.
# Pipeline failures after the run is queued do not fail the site's apply; authentication or queueing failures can.
# The pipeline can be re-run by hand.
action "azureactions_devops_pipeline_trigger" "onboard_client_assets" {
  config {
    project = "Client Assets"
    # pipeline_id is required and must be greater than 0 even when the action is disabled, so 1 stands in for the
    # unconfigured ID. It is never used: enabled is false while the ID is null.
    pipeline_id = coalesce(local.client_assets_onboarding_pipeline_id, 1)
    auth_method = "default_azure_credential"
    # azureactions 1.3.0: false makes the invocation a no-op (no token request, no pipeline run)
    enabled = var.onboard_client_assets && local.client_assets_onboarding_pipeline_id != null

    template_parameters = {
      siteName = var.site_name
    }
  }
}
