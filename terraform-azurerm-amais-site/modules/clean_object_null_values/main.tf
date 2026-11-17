terraform {
  required_version = ">=1.9"
}

variable "object" {
  type = any
}

locals {
  cleaned_object = {
    for k, v in var.object :
    k => (
      v == null ? null : (
        # Handle maps/objects
        can(tomap(v)) ? {
          for sk, sv in tomap(v) :
          sk => sv if sv != null
          } : (
          # Handle lists
          can(tolist(v)) ? tolist([
            for item in tolist(v) :
            item if item != null
            ]) : (
            # Return primitive values as-is
            v
          )
        )
      )
    ) if v != null
  }
}

output "object" {
  value = local.cleaned_object
}
