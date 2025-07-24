output "config_bucket_id" {
  description = "S3 bucket for AWS Config"
  value       = aws_s3_bucket.config.id
}

output "sns_topic" {
  description = "SNS topic for AWS Config notifications"
  value       = aws_sns_topic.config_topic.arn
  
}

output "config_sns_topic_arn" {
  description = "ARN of the SNS topic for AWS Config notifications"
  value       = aws_sns_topic.config_topic.arn
}

output "config_recorder_name" {
  description = "Name of the AWS Config recorder"
  value       = aws_config_configuration_recorder.recorder.name
}