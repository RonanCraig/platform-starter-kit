variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-2"
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the CI roles, in the immutable OIDC subject form owner@owner_id/repo@repo_id (see: gh api repos/OWNER/REPO/actions/oidc/customization/sub)"
  type        = string
  default     = "RonanCraig@28508859/platform-starter-kit@1469237086"
}
