output "organization_id" {
  value = aws_organizations_organization.this.id
}

output "organization_arn" {
  value = aws_organizations_organization.this.arn
}

output "root_id" {
  value = aws_organizations_organization.this.roots[0].id
}

output "organizational_unit_ids" {
  value = { for k, ou in aws_organizations_organizational_unit.this : k => ou.id }
}

output "account_ids" {
  value = { for k, acct in aws_organizations_account.this : k => acct.id }
}