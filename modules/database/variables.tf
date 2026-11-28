variable "name" {
  description = "Prefix for the database name and other resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the database will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where the database will be deployed"
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "ID of the security group that will be allowed to access the database"
  type        = string
}

variable "instance_class" {
  description = "The instance class of the database"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "The version of the database engine"
  type        = string
  default     = "18"
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = "app"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "If true, the DB instance can't be deleted. Safe by default; throwaway environments opt out"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "If true, no final snapshot is taken when the DB instance is deleted. Safe by default; throwaway environments opt out"
  type        = bool
  default     = false
}
