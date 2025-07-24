variable "key_alias" {
  description = "Name for the KMS alias"
  type        = string
}

variable "alias_key_name" {
  description = "Full alias name (alias/xxx)"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Key deletion window"
  type        = number
  default     = 30
}

variable "region" {
  description = "AWS region"
  type        = string
}
