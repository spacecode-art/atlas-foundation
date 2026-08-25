terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2 = "http://localhost:4566"
    rds = "http://localhost:4566"
  }
}

module "network" {
  source = "../../../../terraform/modules/networking"

  environment           = "terratest-db"
  vpc_cidr               = "10.98.0.0/16"
  availability_zones     = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs    = ["10.98.1.0/24", "10.98.2.0/24"]
  private_subnet_cidrs   = ["10.98.101.0/24", "10.98.102.0/24"]
  owner                  = "terratest"
}

module "database" {
  source = "../../../../terraform/modules/database"

  environment        = "terratest-db"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  db_name            = "terratestdb"
  owner              = "terratest"
}