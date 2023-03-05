terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

# Create a new replication subnet group
resource "aws_dms_replication_subnet_group" "subnet-group" {
  replication_subnet_group_description = "Subnet group to DMS resources"
  replication_subnet_group_id          = "01-dms-replication-subnet-group-tf"
  subnet_ids                           =  var.subnets
}

# Create a new replication instance
resource "aws_dms_replication_instance" "replication-instance" {
  allocated_storage            = 20
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  availability_zone            = "us-west-2c"
  engine_version               = "3.1.4"
  multi_az                     = true
  publicly_accessible          = false
  replication_instance_class   = "dms.t2.micro"
  replication_instance_id      = "replication-instance-tf"
  replication_subnet_group_id  = aws_dms_replication_subnet_group.subnet-group.id
  vpc_security_group_ids       = list(var.sg-group)
}

# Create a new Source endpoint (Postgre)
resource "aws_dms_endpoint" "source-endpoint" {
  endpoint_id                 = "dms-endpoint-tf"
  endpoint_type               = "source"
  engine_name                 = "postgres"
  database_name               = var.database-name
  username                    = var.database-user
  password                    = var.database-password
  port                        = var.database-port
  server_name                 = var.database-server
  ssl_mode                    = "none"
}

# Create a new Target endpoint (S3)
resource "aws_dms_s3_endpoint" "target-endpoint" {
  bucket_name             = var.bucket-name
  endpoint_id             = "target-bucket-1"
  endpoint_type           = "target"
  service_access_role_arn = var.target-endpoint-role # Associate a role with S3 read/write access and dms as Principal Service
}

# Create a new database migration task
resource "aws_dms_replication_task" "migration-task" {
  replication_task_id       = "dms-replication-task-tf"
  migration_type            = "cdc"
  table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"public\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
  replication_instance_arn  = aws_dms_replication_instance.replication-instance.replication_instance_arn
  source_endpoint_arn       = aws_dms_endpoint.source-endpoint.endpoint_arn
  target_endpoint_arn       = aws_dms_s3_endpoint.target-endpoint.endpoint_arn
  start_replication_task    = true
}