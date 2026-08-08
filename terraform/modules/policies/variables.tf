variable "policies" {
  description = "SCPs to create"
  type = list(object({
    name        = string
    description = string
    content     = string
  }))
}

variable "policy_attachments" {
  description = "Which policy attaches to which target (OU or account ID)"
  type = list(object({
    policy_name = string
    target_id   = string
  }))
}