provider "aws" {
  region = var.region
  default_tags {
    tags = {
      "Project"   = "platform-starter-kit"
      "ManagedBy" = "Terraform"
    }
  }
}