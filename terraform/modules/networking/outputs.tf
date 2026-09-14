output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}


output "private_route_table_ids" {
  description = "Route table IDs for the private subnets, in the same order as private_subnet_ids and private_subnet_cidrs — needed by consumers (e.g. atlas-network's nat-strategy module) to attach NAT routing"
  value       = aws_route_table.private[*].id
}