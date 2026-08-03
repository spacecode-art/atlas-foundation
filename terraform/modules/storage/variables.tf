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