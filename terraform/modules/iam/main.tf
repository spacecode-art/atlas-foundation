resource "aws_ssoadmin_permission_set" "this" {
  for_each         = { for ps in var.permission_sets : ps.name => ps }
  name             = each.value.name
  description      = each.value.description
  instance_arn     = var.sso_instance_arn
  session_duration = each.value.session_duration
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = {
    for pair in flatten([
      for ps in var.permission_sets : [
        for policy_arn in ps.managed_policy_arns : {
          key        = "${ps.name}-${policy_arn}"
          ps_name    = ps.name
          policy_arn = policy_arn
        }
      ]
    ]) : pair.key => pair
  }

  instance_arn       = var.sso_instance_arn
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.ps_name].arn
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = { for idx, a in var.account_assignments : idx => a }

  instance_arn       = var.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_name].arn

  principal_id   = each.value.principal_id
  principal_type = each.value.principal_type

  target_id   = each.value.target_account_id
  target_type = "AWS_ACCOUNT"
}