variable "trail_name" {
  description = "Name for the CloudTrail"
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
}

variable "enable_cloudwatch_logs" {
  description = "Enable integration with CloudWatch logs"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Allows bucket deletion even with objects inside"
  type        = bool
  default     = false
}

variable "cloudwatch_retention_days" {
  description = "Retention periond for Cloudwatch logs"
  type        = number
  default     = 90
}

variable "cloud_watch_logs_role_arn" {
  description = "IAM role to allow Cloudtrail to write to Cloudwathc logs"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for encrypting CloudTrail logs"
  type        = string
}