resource "aws_organizations_policy" "this" {
  for_each    = { for p in var.policies : p.name => p }
  name        = each.value.name
  description = each.value.description
  content     = each.value.content
  type        = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "this" {
  for_each = { for idx, a in var.policy_attachments : idx => a }

  policy_id = aws_organizations_policy.this[each.value.policy_name].id
  target_id = each.value.target_id
}