output "permission_set_arns" {
  value = { for k, ps in aws_ssoadmin_permission_set.this : k => ps.arn }
}