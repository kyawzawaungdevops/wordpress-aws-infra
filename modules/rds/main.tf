resource "aws_db_subnet_group" "main" {
  name       = "appdb-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.prefix}-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.prefix}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EC2 only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_sg_id]          # ← only EC2 can reach RDS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "main" {
  identifier        = "production-rds-instance"
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az               = var.multi_az
  publicly_accessible    = false                # ← never public
  skip_final_snapshot    = false
  final_snapshot_identifier = "${var.prefix}-final-snapshot"
  deletion_protection    = var.deletion_protection

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  tags = {
    Name = var.prefix
  }
}

output "db_host" {
  description = "RDS hostname only, port stripped"
  value       = split(":", aws_db_instance.main.endpoint)[0]
}