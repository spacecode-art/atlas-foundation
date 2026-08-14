provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"  
  skip_credentials_validation = true #    nosemgrep: terraform.aws.security.aws-provider-static-credentials.aws-provider-static-credentials -- MiniStack placeholder, not a real credential; see atlas-security ADR-0003
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3            = "http://localhost:4566"
    dynamodb      = "http://localhost:4566"
    organizations = "http://localhost:4566"
    ssoadmin      = "http://localhost:4566"

  }
}