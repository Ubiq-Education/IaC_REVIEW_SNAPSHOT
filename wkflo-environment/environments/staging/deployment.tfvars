environment = "staging"
regions_enabled = {
  "uksouth" = {
    custom_domain_and_cert_enabled = true
    maintenance_window = {
      durationHours = 8
      startHourUtc  = 23
      weekDay       = "Sunday"
    }
    postgresql_config = {
      sku_name = "B_Standard_B2ms"
      maintenance_window = {
        day_of_week  = 1
        start_hour   = 0
        start_minute = 0
      }
    }
  }
}
