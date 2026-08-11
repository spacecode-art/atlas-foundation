variable "environment" {
  type    = string
  default = "terratest"
}

variable "vpc_cidr" {
  type    = string
  default = "10.99.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.99.1.0/24", "10.99.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.99.101.0/24", "10.99.102.0/24"]
}