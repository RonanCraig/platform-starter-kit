variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-2"
}

variable "enable_nat_gateway" {
  description = "Whether to enable a NAT gateway for private subnets"
  type        = bool
  default     = false
}