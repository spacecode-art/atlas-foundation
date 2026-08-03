module "app_storage" {
  source = "../../modules/storage"

  bucket_name       = "atlas-dev-app-storage"
  environment       = "development"
  enable_versioning = false
}