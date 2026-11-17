locals {
  sub_id          = "da462007-44f7-4547-ab47-679054904e30"
  deployment_name = "grafana-logging-${var.environment}"
  tags = merge(
    {
      deployment_method = "terraform"
      environment       = var.environment
    }, var.tags
  )
  regions = toset(var.regions)
  twingate_ip_restrictions = {
    tg1 = {
      action               = "Allow"
      name                 = data.azurerm_subnet.hub_centralindia_tg.name
      vnetSubnetResourceId = data.azurerm_subnet.hub_centralindia_tg.id
    }
    tg2 = {
      action               = "Allow"
      name                 = data.azurerm_subnet.hub_uksouth_tg.name
      vnetSubnetResourceId = data.azurerm_subnet.hub_uksouth_tg.id
    }
  }
  devops_sh_ip_restrictions = {
    devops1 = {
      action               = "Allow"
      name                 = data.azurerm_subnet.hub_uksouth_devops_01.name
      vnetSubnetResourceId = data.azurerm_subnet.hub_uksouth_devops_01.id
    }
    devops2 = {
      action               = "Allow"
      name                 = data.azurerm_subnet.hub_uksouth_devops_02.name
      vnetSubnetResourceId = data.azurerm_subnet.hub_uksouth_devops_02.id
    }
  }
  tag_restrictions = {
    eventhub = {
      action = "Allow"
      name   = "EventHub"
      tag    = "EventHub"
    }
  }
  # merger of all ip restrictions
  all_ip_restrictions     = merge(local.devops_sh_ip_restrictions, local.twingate_ip_restrictions, local.tag_restrictions)
  all_scm_ip_restrictions = merge(local.devops_sh_ip_restrictions, local.twingate_ip_restrictions)
}
