resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "db" {
  name_prefix = "${var.name}-db-"
  lifecycle { create_before_destroy = true }
  description = "Security group for DB"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.name}-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_ingress" {
  description                  = "Allow access to the database from app instances only"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.allowed_security_group_id
  security_group_id            = aws_security_group.db.id
}

resource "aws_db_instance" "this" {
  # checkov:skip=CKV_AWS_157:Multi-AZ doubles the cost; exposed as var.multi_az for production to enable
  # checkov:skip=CKV_AWS_118:Enhanced monitoring needs an extra IAM role and CloudWatch cost; Performance Insights covers DB-level metrics
  # checkov:skip=CKV_AWS_354:Performance Insights data is encrypted with the AWS managed key; a customer-managed KMS key ($1/month) is only needed for key-policy control
  # checkov:skip=CKV2_AWS_30:Query logging needs a custom parameter group and logging every statement is noisy and costly at this stage
  identifier                  = "${var.name}-db"
  tags                        = { Name = "${var.name}-db" }
  engine_version              = var.engine_version
  db_name                     = var.db_name
  instance_class              = var.instance_class
  storage_type                = "gp3"
  allocated_storage           = var.allocated_storage
  engine                      = "postgres"
  auto_minor_version_upgrade  = true
  username                    = "app_admin"
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.db.id]
  publicly_accessible         = false
  storage_encrypted           = true
  backup_retention_period     = 7
  multi_az                    = var.multi_az
  deletion_protection         = var.deletion_protection
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.skip_final_snapshot ? null : "${var.name}-final"

  iam_database_authentication_enabled   = true # apps can log in with short-lived IAM tokens instead of the password
  copy_tags_to_snapshot                 = true # snapshots keep cost-tracking tags
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade", "iam-db-auth-error"]
  performance_insights_enabled          = true
  performance_insights_retention_period = 7 # free tier retention
}
