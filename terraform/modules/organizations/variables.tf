variable "organizational_units" {
  description = "Names of Organizational Units to create directly under the org root"
  type        = list(string)
}

variable "accounts" {
  description = "Accounts to create, each assigned to one OU by name"
  type = list(object({
    name  = string
    email = string
    ou    = string
  }))
}