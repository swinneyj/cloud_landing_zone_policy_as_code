output "key_arn" {
  description = "ARN of the created KMS key"
  value       = aws_kms_key.kms_key.arn
}

output "alias_name" {
  description = "Alias name of the KMS key"
  value       = aws_kms_alias.kms_alias.name
}
