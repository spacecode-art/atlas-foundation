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
    ssoadmin = "http://localhost:4566"
  }
}

module "iam" {
  source = "../../../../terraform/modules/iam"

  sso_instance_arn = "arn:aws:sso:::instance/ssoins-testexample0000"

  permission_sets = [
    {
      name                = "TestReadOnly"
      description         = "Terratest fixture permission set"
      session_duration    = "PT1H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    }
  ]

  account_assignments = []
}