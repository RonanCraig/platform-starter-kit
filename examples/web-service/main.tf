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

module "database" {
  source                    = "../../modules/database"
  name                      = "starter-dev"
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  allowed_security_group_id = module.service.instance_security_group_id

  # Throwaway example: allow terraform destroy without a leftover snapshot.
  # checkov:skip=CKV_AWS_293:Example stack is destroyed after every test; the module itself defaults to deletion protection on
  deletion_protection = false
  skip_final_snapshot = true
}
