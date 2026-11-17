variable "environment" {
  type        = string
  description = <<DESCRIPTION
  The environment for which the resources are being created (e.g. staging, prod). Use in names and tags."
  Changing will result in resource recreation.
  DESCRIPTION
}

variable "regions" {
  type        = list(string)
  description = "Azure regions in which to deploy log forwarding infrastructure."
}

variable "loki_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to the resources"
}
