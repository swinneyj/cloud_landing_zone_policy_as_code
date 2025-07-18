
# Cloud Landing Zone with Terraform

## Overview

This repository contains a foundational cloud infrastructure project that establishes a secure, scalable, and automated landing zone in AWS using Terraform. It is designed for enterprises and cloud-native teams adopting a multi-account strategy and Infrastructure as Code (IaC) practices. 

The architecture reflects industry-standard best practices for network segmentation, access control, logging, and encryption—setting the stage for secure application and workload deployment across environments.

---

## Modules Included

### 1. `network`
A reusable module to provision a VPC with public and private subnets, internet gateway, NAT gateway, and route tables. This supports highly available and fault-tolerant architecture patterns.

**Features:**
- Customizable CIDR blocks
- Public/private subnet creation
- Multi-AZ support
- NAT for outbound traffic
- Internet gateway for public-facing workloads

### 2. `iam`
A lightweight IAM module that provisions IAM roles and managed policies with a customizable trust relationship and policy document.

**Features:**
- Custom assume role policy
- Least-privilege custom policy
- Reusable for cross-account or service-specific IAM roles

### 3. `s3`
This module provisions secure and compliant S3 buckets intended for log aggregation, state storage, or general-purpose use.

**Features:**
- Server-side encryption (AES256)
- Versioning support
- Block all public access
- Optional access logging to a central bucket

---

## Structure

```
terraform/
├── modules/
│   ├── network/
│   ├── iam/
│   └── s3/
└── environments/
    ├── dev/
    └── prod/
```

Each environment defines its own stack and can reuse core modules to ensure configuration consistency while supporting environment-specific parameters.

---

## Getting Started

### Prerequisites
- [Terraform v1.5+](https://www.terraform.io/downloads.html)
- AWS CLI with credentials configured via IAM or environment variables

### Initialization and Deployment
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

---

## Security Posture and Intent

This project is designed with security-first principles:
- All resources are tagged and encrypted
- No S3 buckets are publicly accessible
- IAM follows least privilege and explicitly defined trust boundaries
- Infrastructure is modular and reproducible for scaling across multiple AWS accounts

---

## Future Work

- Policy-as-Code integration (OPA/Conftest)
- CI/CD for automated provisioning and validation
- Centralized logging with CloudTrail and AWS Config
- GuardDuty and security alerting
- Remote state configuration with locking

---

## Author

Josh Swinn  
Cloud Security Engineer | DevOps Enthusiast | Infrastructure Architect  
[josh_swinn](https://github.com/josh_swinn)

---

*This repository serves as both a practical implementation and a showcase of core cloud engineering competencies related to AWS, Terraform, and secure-by-default architecture.*
