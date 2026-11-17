variable "get_vnets" {
  type        = bool
  default     = false
  description = "Lookup all the virtual networks"
}

variable "get_securegw_pips" {
  type        = bool
  default     = false
  description = "Lookup NAT Secure Gateway Public IPs"
}

variable "get_pum" {
  type        = bool
  default     = false
  description = "Lookup PUM API details"
}

variable "get_google_bot_ips" {
  type        = bool
  default     = false
  description = "Lookup Google user-triggered fetcher IP ranges"
}
