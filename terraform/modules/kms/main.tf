resource "aws_kms_key" "kms_key" {
  description             = "KMS key for ${var.alias_key_name}"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
}

resource "aws_kms_alias" "kms_alias" {
  name          = var.alias_key_name
  target_key_id = aws_kms_key.kms_key.id
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid     = "AllowAccountAdmins"
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = [aws_kms_key.kms_key.arn]
  }

  statement {
    sid     = "AllowCloudServices"
    effect  = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      type        = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
        "config.amazonaws.com",
        "logs.amazonaws.com"
      ]
    }
    resources = [aws_kms_key.kms_key.arn]
  }
}

resource "aws_kms_key_policy" "key_policy" {
  key_id = aws_kms_key.kms_key.id
  policy = data.aws_iam_policy_document.kms_policy.json
}