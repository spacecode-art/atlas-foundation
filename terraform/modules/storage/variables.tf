variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
}

variable "environment" {
  description = "Environment this bucket belongs to (used for tagging)"
  type        = string
}

variable "enable_versioning" {
  description = "Whether to enable object versioning on the bucket"
  type        = bool
  default     = false
}

variable "owner" {
  description = "Team or individual accountable for this resource (tagging policy requires this — see atlas-security policies/opa/tagging.rego)"
  type        = string
}