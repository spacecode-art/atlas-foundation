module "organizations" {
  source = "../../modules/organizations"

  organizational_units = ["Security", "Shared", "Workloads"]

  accounts = [
    {
      name  = "atlas-security"
      email = "prime+security@example.com"
      ou    = "Security"
    },
    {
      name  = "atlas-shared-services"
      email = "prime+shared@example.com"
      ou    = "Shared"
    },
    {
      name  = "atlas-development"
      email = "prime+dev@example.com"
      ou    = "Workloads"
    },
    {
      name  = "atlas-staging"
      email = "prime+staging@example.com"
      ou    = "Workloads"
    },
    {
      name  = "atlas-production"
      email = "prime+prod@example.com"
      ou    = "Workloads"
    },
  ]
}


