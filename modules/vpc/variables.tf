variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "name" {
  type        = string
  description = "The name of the VPC and its resources"
}

variable "az_count" {
  description = "The number of availability zones to use"
  type        = number
  default     = 2
  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "The number of availability zones must be between 2 and 3"
  }
}

variable "enable_nat_gateway" {
  description = "Whether to enable a NAT gateway for private subnets"
  type        = bool
  default     = false
}