output "db_instance_id" {
  value = module.database.db_instance_endpoint
}

output "db_security_group_id" {
  value = module.database.db_security_group_id
}