output "address" {
  description = "The address of the database"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "The port of the database"
  value       = aws_db_instance.this.port
}

output "security_group_id" {
  description = "The security group ID of the database"
  value       = aws_security_group.db.id
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the master password (managed and rotated by RDS)"
  value       = one(aws_db_instance.this.master_user_secret[*].secret_arn)
}
