variable "sso_instance_arn" {
  description = "ARN of the existing IAM Identity Center instance (must already be enabled manually — cannot be created via Terraform)"
  type        = string
}

variable "permission_sets" {
  description = "Permission sets to define"
  type = list(object({
    name                = string
    description         = string
    session_duration    = string
    managed_policy_arns = list(string)
  }))
}

variable "account_assignments" {
  description = "Which permission set applies to which principal, on which account"
  type = list(object({
    permission_set_name = string
    principal_type       = string # "USER" or "GROUP"
    principal_id          = string
    target_account_id     = string
  }))
}