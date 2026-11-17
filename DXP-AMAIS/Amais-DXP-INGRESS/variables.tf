variable "syslog_token" {
  type        = string
  sensitive   = true
  default     = null
  description = "Syslog token to use for log forwarding to global receivers"
}
