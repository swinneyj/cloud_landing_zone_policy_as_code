output "cloudtrail_bucket" {
  value = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_trail_arn" {
  value = aws_cloudtrail.main.arn
}

output "cloudtrail_bucket_name" {
  value       = aws_s3_bucket.cloudtrail.bucket
  description = "The s3 bucket name where CT stores logs"
}

output "cloudwatch_logs_group_arn" {
  description = "ARN of the CloudWatch log group for CloudTrail logs"
  value       = try(aws_cloudwatch_log_group.cloudtrail[0].arn, null)
}