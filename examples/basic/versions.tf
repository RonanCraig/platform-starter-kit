terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws" # where to download it from (the Terraform Registry)
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "psk-tfstate-535515637778-eu-west-2"
    key          = "examples/basic/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
