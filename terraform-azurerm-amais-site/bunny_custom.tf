# Remove workaround rest resources for bot categorisation as these are now supported by the bunny provider natively

removed {
  from = restful_resource.bunny_shield_bot_action

  lifecycle {
    destroy = false
  }
}

removed {
  from = restful_resource.bunny_shield_category_action

  lifecycle {
    destroy = false
  }
}
