environment = "prod"
regions_enabled = {
  "uksouth" = {
    custom_domain_and_cert_enabled = true
    maintenance_window = {
      durationHours = 8
      startHourUtc  = 23
      weekDay       = "Wednesday"
    }
  }
}
