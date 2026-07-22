resource "aws_db_subnet_group" "default" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "random_password" "db" {
  length           = var.db_password_length
  override_special = "!#$%^&*()-_=+[]{}:;?,.<>"
  special          = true
  upper            = true
  lower            = true
  numeric          = true
}

resource "aws_db_instance" "postgres" {
  identifier              = "devops-academico-db"
  engine                  = "postgres"
  engine_version          = "16"
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.db.result
  allocated_storage       = var.db_allocated_storage
  max_allocated_storage   = var.db_allocated_storage
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [var.security_group_id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
  backup_retention_period = 0
  apply_immediately       = true

  tags = {
    Name = "devops-academico-postgres"
  }
}
