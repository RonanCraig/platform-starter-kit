module "vpc" {
  source   = "../../modules/vpc"
  name     = "starter-dev"
  vpc_cidr = "10.0.0.0/16"
  az_count = 2
}

module "service" {
  source             = "../../modules/service"
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  name               = "starter-dev"
  vpc_id             = module.vpc.vpc_id
}
