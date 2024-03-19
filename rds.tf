resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.primary.id, aws_subnet.standby.id, aws_subnet.replica.id]

  tags = {
    Name = "DBSubnetGroup"
  }
}

resource "aws_db_instance" "primary" {
  identifier              = "primary-instance"
  storage_type            = "gp2"
  engine_version          = "8.0.28"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "myDb"
  username                = "admin"
  password                = "VeryStrongPa33word"
  db_subnet_group_name    = aws_db_subnet_group.main.name
  multi_az                = true
  publicly_accessible     = true
  skip_final_snapshot     = true
  backup_retention_period = 1

  blue_green_update {
    enabled = true
  }
}

resource "aws_db_instance" "read_replica" {
  identifier          = "read-replica"
  instance_class      = "db.t3.micro"
  publicly_accessible = true
  skip_final_snapshot = true
  replicate_source_db = aws_db_instance.primary.identifier
  availability_zone   = "us-east-1c"
}

resource "aws_db_parameter_group" "allow-write" {
  name   = "rds-allow-write"
  family = "mysql8.0"

  parameter {
    name  = "read_only"
    value = 0
  }
}

output "primary_db_endpoint" {
  value = aws_db_instance.primary.endpoint
}

output "primary_db_arn" {
  value = aws_db_instance.primary.arn
}

output "read_replica_endpoint" {
  value = aws_db_instance.read_replica.endpoint
}

output "read_replica_arn" {
  value = aws_db_instance.read_replica.arn
}