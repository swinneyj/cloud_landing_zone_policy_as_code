variable "alias_key_name" {
  description = "Name of the KMS key alias"
  type        = string
}

resource "aws_kms_key" "kms_key" {
  description = "Alias for the KMS Key"
  //description = "KMS key for alias ${var.alias_key_name}"
  deletion_window_in_days = var.deletion_window_in_days
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_key.kms_key.id
}

##Key Policy for the KMS Key
## Allows the account root to adminster the key
## Allows Cloudtrail to encrypt/decrypt using the key
##Grants decryption to a securiyt role
data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid     = "AllowAccountAdmins"
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }

  statement {
    sid     = "AllowCloudTrailService"
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
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = ["*"]
  }

    # Allow CloudWatch Logs to use the key for log group encryption
  statement {
    sid     = "AllowCloudWatchLogsService"
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
      identifiers = ["logs.${var.region}.amazonaws.com"] # or hardcode us-east-1
    }
    resources = ["*"]
  }

  #Allow a security/auditing role to decrypt
  statement {
    sid     = "AllowSecurityTeamDecrypt"
    effect  = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key_policy" "key_policy" {
  key_id = aws_kms_key.kms_key.id
  policy = data.aws_iam_policy_document.kms_policy.json
}

data "aws_caller_identity" "current" {}