output "state_bucket_name" {
  description = "Name of the S3 bucket used to store Terraform state"
  value       = aws_s3_bucket.tfstate.bucket
}

output "github_plan_role_arn" {
  description = "ARN of the IAM role used by GitHub Actions to plan Terraform changes"
  value       = aws_iam_role.github_plan.arn
}
