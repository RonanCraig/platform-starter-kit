terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws" # where to download it from (the Terraform Registry)
      version = "~> 6.0"
    }
  }
}
