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

  endpoints {
    organizations = "http://localhost:4566"
  }
}

module "organizations" {
  source = "../../../../terraform/modules/organizations"

  organizational_units = ["TestOU"]

  accounts = [
    {
      name  = "test-account"
      email = "terratest-fixture@example.com"
      ou    = "TestOU"
    }
  ]
}