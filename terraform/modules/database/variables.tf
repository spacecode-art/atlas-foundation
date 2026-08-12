variable "environment" {
  description = "Environment name, used for tagging and naming"
  type        = string
}

variable "owner" {
  description = "Team or individual accountable for this resource (tagging policy requires this — see atlas-security policies/opa/tagging.rego)"
  type        = string
}

variable "vpc_id" {
  description = "VPC to place the database in"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group (minimum 2, different AZs)"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to reach the database (e.g. an app tier's SG)"
  type        = list(string)
  default     = []
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "16.3"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "atlas_admin"
}

variable "skip_final_snapshot" {
  description = "Skip taking a final snapshot on deletion (safe for dev, dangerous for staging/production)"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Prevent accidental deletion via Terraform or console"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Enable Multi-AZ failover (adds cost, appropriate for staging/production)"
  type        = bool
  default     = false
}
variable "backup_retention_period" {
  description = "Number of days to retain automated backups (0 disables backups)"
  type        = number
  default     = 7
}