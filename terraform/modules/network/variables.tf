variable "name_prefix" {
  description = "Prefix for naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnet"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets"
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}