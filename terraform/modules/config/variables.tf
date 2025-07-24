variable "region" {
  description = "AWS region"
  type        = string
}

variable "name_prefix" {
    description = "Prefix for AWS Config resources"
    type        = string
}

variable "config_bucket_name" {
    description = "Name of the S3 bucket for AWS Config"
    type        = string
}

variable "kms_key_arn" {
    description = "KMS master key ID for encryption"
    default = null
    type = string
}