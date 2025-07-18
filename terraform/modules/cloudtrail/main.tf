// CloudTrail logging

resource "aws_iam_role" "cloudtrail_cw_role" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name = "${var.trail_name}-cwlogs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "cloudtrail_cw_policy" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name = "${var.trail_name}-cwlogs-policy"
  role = aws_iam_role.cloudtrail_cw_role[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"],
      Resource = "*"
    }]
  })
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = var.cloudtrail_bucket_name
  force_destroy = var.force_destroy

  tags = {
    Name = var.cloudtrail_bucket_name
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSCloudTrailWrite",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid    = "AWSCloudTrailAclCheck",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.cloudtrail.arn
      }
    ]
  })
}

//provides resource for controlling versioning on S3 bucket
resource "aws_s3_bucket_versioning" "cloudtrail_versioning" {
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration {
    status = "Enabled"
  }

}

//Provide a S3 bucket server-side encryption config resource
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_encryption" {
  bucket = aws_s3_bucket.cloudtrail.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

//Manage S3 bucket-level pulic access block config
resource "aws_s3_bucket_public_access_block" "cloudtrail_block" {
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

//Provides a CloudWatch log group resource
resource "aws_cloudwatch_log_group" "cloudtrail" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/cloudtrail/${var.trail_name}"
  retention_in_days = var.cloudwatch_retention_days
}

//Provides a cloudtrail resource
resource "aws_cloudtrail" "main" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = try("${aws_cloudwatch_log_group.cloudtrail[0].arn}:*", null)
  cloud_watch_logs_role_arn  = try(aws_iam_role.cloudtrail_cw_role[0].arn, null)

  depends_on = [
    aws_s3_bucket.cloudtrail,
    aws_cloudwatch_log_group.cloudtrail,
    aws_iam_role.cloudtrail_cw_role
  ]

}

