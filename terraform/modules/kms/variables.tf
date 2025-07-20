variable "key_alias" {
  description = "Alias for the KMS key"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Number of days before a scheduled KMS key deletion (7–30)"
  type        = number
  default     = 30
}

variable "region" {
  description = "Region for the KMS key"
  type        = string
  default     = "us-east-1"
}