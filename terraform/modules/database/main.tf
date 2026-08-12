locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "atlas-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "atlas-${var.environment}-db-subnet-group"
  })
}

resource "aws_security_group" "db" {
  name        = "atlas-${var.environment}-db-sg"
  description = "Allow database access only from specified security groups"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "atlas-${var.environment}-db-sg"
  })
}

resource "aws_security_group_rule" "db_ingress" {
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = var.allowed_security_group_ids[count.index]
}



resource "aws_db_instance" "this" {
  identifier     = "atlas-${var.environment}-db"
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  storage_encrypted     = true

  db_name                     = var.db_name
  username                    = var.master_username
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible          = false
  skip_final_snapshot          = var.skip_final_snapshot
  deletion_protection          = var.deletion_protection
  multi_az                     = var.multi_az
  copy_tags_to_snapshot        = true
  auto_minor_version_upgrade   = true
  backup_retention_period      = var.backup_retention_period
  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(local.common_tags, {
    Name = "atlas-${var.environment}-db"
  })
}

