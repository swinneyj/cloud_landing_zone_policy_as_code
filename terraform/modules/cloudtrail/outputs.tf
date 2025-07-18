output "cloudtrail_bucket" {
  value = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_trail_arn" {
  value = aws_cloudtrail.main.arn
}