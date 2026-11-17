resource "bunnynet_pullzone_edgerule" "add_x_headers" { # add_x_azure_fdid
  enabled     = true
  pullzone    = bunnynet_pullzone.main.id
  description = "Add X Headers"
  priority    = 1

  actions = flatten([
    [
      {
        type       = "SetRequestHeader"
        parameter1 = "X-Forwarded-Host"
        parameter2 = "%%{Url.Hostname}" # First % to escape, %{Url.Hostname} passed to Bunny
        parameter3 = null
      }
    ],
    var.x_azure_fdid_value != null ? [
      {
        type       = "SetRequestHeader"
        parameter1 = "X-Azure-FDID"
        parameter2 = var.x_azure_fdid_value
        parameter3 = null
      }
    ] : []
  ])
  match_type = "MatchAny"
  triggers = [
    {
      type       = "Url"
      match_type = "MatchAny"
      patterns   = ["*"]
      parameter1 = null
      parameter2 = null
    }
  ]
}

resource "bunnynet_pullzone_edgerule" "main" {
  for_each = var.pullzone_edge_rules

  enabled     = each.value.enabled
  pullzone    = bunnynet_pullzone.main.id
  description = each.value.description
  priority    = each.value.priority
  actions     = each.value.actions
  match_type  = each.value.match_type
  triggers    = each.value.triggers
}
