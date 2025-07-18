// Dev environment setup
provider "aws" {
  region = "us-east-1"
}

module "network" {
  source               = "../../modules/network"
  name_prefix          = "dev"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  azs                  = ["us-east-1a", "us-east-1b"]
}

output "subnet_ids" {
  value = module.network.vpc_id
}

output "public_subnets" {
  value = module.network.public_subnets_ids[*]
}

module "iam_ec2_admin" {
  source      = "../../modules/iam"
  name_prefix = "dev-ec2-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  policy_json = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ec2:*",
        Resource = "*"
      }
    ]
  })
}

module "cloudtrail" {
  source                    = "../../modules/cloudtrail"
  trail_name                = "dev-org-trail"
  cloudtrail_bucket_name    = "dev-cloudtrail-logs-${random_id.suffix.hex}"
  enable_cloudwatch_logs    = true
  force_destroy             = true
  cloudwatch_retention_days = 180
  cloud_watch_logs_role_arn = "arn:aws:iam::123456789012:role/CloudTrailCWLogsRole"
}

resource "random_id" "suffix" {
  byte_length = 4
}