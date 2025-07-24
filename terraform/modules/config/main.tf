provider "aws" {
  region = var.region
}

//S3 bucket for snapshhots
resource "aws_s3_bucket" "config" {
  bucket = var.config_bucket_name
  force_destroy = true

   tags = {
    Name = var.config_bucket_name
   }
}

resource "aws_s3_bucket_policy" "config" {
    bucket = aws_s3_bucket.config.id


  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSConfigBucketPermissionsCheck",
        Effect    = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action    = "s3:GetBucketAcl",
        Resource  = aws_s3_bucket.config.arn
      },
      {
        Sid       = "AWSConfigBucketDelivery",
        Effect    = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.config.arn}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

//Enables S3 bucket versioning for compliance
resource "aws_s3_bucket_versioning" "config" {
    bucket = aws_s3_bucket.config.id
    
    versioning_configuration {
        status = "Enabled"
    }
}

//Server-side encryption with KMS for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
    bucket = aws_s3_bucket.config.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "aws:kms"
            kms_master_key_id = var.kms_key_arn
            //kms_master_key_id = module.kms.key_arn - not referenced correctly
        }
    }
}

//block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "config" {
    bucket = aws_s3_bucket.config.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

//SNS topic for notifications, encrypted with KMS
resource "aws_sns_topic" "config_topic" {
    name = "${var.name_prefix}-config-topic"
    kms_master_key_id = var.kms_key_arn
}

//IAM role for AWS Config
resource "aws_iam_role" "config_role" {
  name               = "${var.name_prefix}-config-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-config-role"
  }
}

//Atach AWS managed policy to the IAM role
resource "aws_iam_role_policy_attachment" "config_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

//Provide an AWS Config Configuration Recorder
//This does not start the recorder automatically, it requires a delivery channel to be created
resource "aws_config_configuration_recorder" "recorder" {
  name     = "${var.name_prefix}-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
    include_global_resource_types = true
  }

  depends_on = [aws_iam_role_policy_attachment.config_policy]
}

//Delivery Channel for Recorder (depends on the recorder, bucket, and topic)
resource "aws_config_delivery_channel" "channel" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config.id
  sns_topic_arn  = aws_sns_topic.config_topic.arn

  depends_on = [
    aws_config_configuration_recorder.recorder,
    aws_s3_bucket.config,
    aws_sns_topic.config_topic
  ]
}

//Resource block to start the configuration recorder
resource "aws_config_configuration_recorder_status" "recorder_status" {
  name   = aws_config_configuration_recorder.recorder.name
    is_enabled = true

    depends_on = [
        aws_config_configuration_recorder.recorder,
        aws_config_delivery_channel.channel
    ]
}

//Setup baseline managed rules (for CIS Foundations)
resource "aws_config_config_rule" "cis_root_account_mfa" {
  name = "cis-root-account-mfa"
  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

      depends_on = [
        aws_config_configuration_recorder.recorder,
        aws_config_delivery_channel.channel
    ]
}

resource "aws_config_config_rule" "cis_iam_password_policy" {
    name = "cis-iam-password-policy"
    source {
        owner = "AWS"
        source_identifier = "IAM_PASSWORD_POLICY"
    }

        depends_on = [
        aws_config_configuration_recorder.recorder,
        aws_config_delivery_channel.channel
    ]
}