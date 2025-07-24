//Guard Duty related variables
variable "region" {
  description = "The AWS region where GuardDuty and Security Hub will be deployed."
  type        = string
}

variable "name_prefix" {     
  description = "A prefix for Security Resoureces"
  type        = string
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key to use for encrypting GuardDuty findings."
  type        = string
}

variable "enable_pci" {
  description = "Enable PCI DSS standard in Security Hub"
  type        = bool
  default     = false
}

//Guard Duty Setup
resource aws_guardduty_detector "main" {
  enable = true
}