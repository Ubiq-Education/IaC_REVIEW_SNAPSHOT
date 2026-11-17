output "container_app" {
  description = "The Container App resource."
  value       = var.ignore_image_version ? azapi_resource.versionless[0] : azapi_resource.versioned[0]
}
