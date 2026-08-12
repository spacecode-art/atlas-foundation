module "app_storage" {
  source = "../../modules/storage"

  bucket_name       = "atlas-dev-app-storage"
  environment       = "development"
  enable_versioning = true
  owner             = "platform-team"
}

module "network" {
  source = "../../modules/networking"

  environment           = "development"
  vpc_cidr               = "10.0.0.0/16"
  availability_zones     = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24"]
  owner                  = "platform-team"
}



module "database" {
  source = "../../modules/database"

  environment         = "development"
  vpc_id              = module.network.vpc_id
  private_subnet_ids  = module.network.private_subnet_ids
  db_name             = "atlasdev"
  owner               = "platform-team"
}