output "policy_ids" {
  value = { for k, p in aws_organizations_policy.this : k => p.id }
}