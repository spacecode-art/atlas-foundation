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

module "iam" {
  source = "../../modules/iam"

  sso_instance_arn = "arn:aws:sso:::instance/ssoins-example00000000"

  permission_sets = [
    {
      name                = "AdministratorAccess"
      description         = "Full administrative access"
      session_duration    = "PT4H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    },
    {
      name                = "ReadOnlyAccess"
      description         = "Read-only access for auditing"
      session_duration    = "PT8H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    },
  ]

  account_assignments = []
}


