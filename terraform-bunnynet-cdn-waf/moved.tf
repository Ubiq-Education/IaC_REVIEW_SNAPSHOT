moved {
  from = bunnynet_pullzone_edgerule.add_x_azure_fdid[0]
  to   = bunnynet_pullzone_edgerule.add_x_headers
}

moved {
  from = bunnynet_pullzone_shield.main
  to   = bunnynet_pullzone_shield.main[0]
}

moved {
  from = time_sleep.bunnynet_pullzone_shield
  to   = time_sleep.bunnynet_pullzone_shield[0]
}
