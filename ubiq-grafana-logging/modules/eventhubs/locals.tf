locals {
  indexed_consumer_groups = {
    for cg in flatten([
      for event_hub, details in var.event_hubs : [
        for consumer_group in details.consumer_groups : {
          consumer_group = consumer_group
          event_hub      = event_hub
        }
      ]
    ]) : "${cg.event_hub}-${cg.consumer_group}" => cg
  }
  eventhub_data_sender_roles = {
    for role in flatten([
      for event_hub, details in var.event_hubs : [
        for principal_id in details.data_sender_principal_ids : {
          principal_id = principal_id
          event_hub    = event_hub
        }
      ]
    ]) : "${role.event_hub}-${role.principal_id}" => role
  }
  eventhub_data_receiver_roles = {
    for role in flatten([
      for event_hub, details in var.event_hubs : [
        for principal_id in details.data_receiver_principal_ids : {
          principal_id = principal_id
          event_hub    = event_hub
        }
      ]
    ]) : "${role.event_hub}-${role.principal_id}" => role
  }
}
