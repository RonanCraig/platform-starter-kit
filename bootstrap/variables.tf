variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-2"
}

variable "github_repo" {
  description = "The GitHub repository allowed to assume the CI roles"
  type        = string
  default     = "RonanCraig/platform-starter-kit"
}
