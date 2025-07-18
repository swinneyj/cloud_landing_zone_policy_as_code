variable "name_prefix" {
  type        = string
  description = "Prefix for IAM role/policy name"
}

variable "assume_role_policy" {
  type        = string
  description = "JSON policy defining who can assume role"
}

variable "policy_json" {
  type        = string
  description = "IAM policy as JSON"
}

variable "policy_description" {
  type    = string
  default = "Managed by Terraform"
}