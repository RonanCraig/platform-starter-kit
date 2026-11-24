module "vpc" {
  source             = "../../modules/vpc"
  name               = "starter-dev"
  vpc_cidr           = "10.0.0.0/16"
  az_count           = 2
  enable_nat_gateway = var.enable_nat_gateway
}