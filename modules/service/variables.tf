variable "name" {
  type        = string
  description = "The name of the Service and its resources"
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the Service into"
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets to deploy the Service into"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets to deploy the Service into"
  type        = list(string)
}

variable "instance_type" {
  description = "The EC2 instance type for the Service"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "The minimum number of instances in the Auto Scaling group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "The maximum number of instances in the Auto Scaling group"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "The initial number of instances in the Auto Scaling group (scaling policies manage it after creation)"
  type        = number
  default     = 2
}

variable "app_port" {
  description = "The port on which the application will listen"
  type        = number
  default     = 80
}
