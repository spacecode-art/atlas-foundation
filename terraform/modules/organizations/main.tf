resource "aws_organizations_organization" "this" {
  feature_set = "ALL"

  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
  ]
}

resource "aws_organizations_organizational_unit" "this" {
  for_each  = toset(var.organizational_units)
  name      = each.value
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_account" "this" {
  for_each  = { for acct in var.accounts : acct.name => acct }
  name      = each.value.name
  email     = each.value.email
  parent_id = aws_organizations_organizational_unit.this[each.value.ou].id

  lifecycle {
    ignore_changes = [role_name]
  }
}