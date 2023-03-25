#Set Random DB password

resource "random_string" "db_password" {
  length  = 32
  special = false
  upper   = false
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.client}/${var.project}/${var.environment}/db_password"
  description = "The ${var.project} - ${var.environment} Database Password"
  type        = "SecureString"
  value       = random_string.db_password.result
}

#Mysql Serverless Aurora

resource "aws_rds_cluster" "mysql" {
  cluster_identifier           = var.cluster_identifier
  copy_tags_to_snapshot        = true
  database_name                = var.dbname
  deletion_protection          = var.termination_protection
  master_password              = random_string.db_password.result
  master_username              = var.dbuser
  skip_final_snapshot          = var.skip_final_snapshot
  final_snapshot_identifier    = "${var.project}-${var.environment}-final"
  backup_retention_period      = 35
  preferred_backup_window      = "04:00-06:00"
  preferred_maintenance_window = "sun:06:00-sun:08:00"
  vpc_security_group_ids       = [aws_security_group.mysql_rds_sg.id]
  storage_encrypted            = true
  apply_immediately            = false
  db_subnet_group_name         = var.mysql_rds_subnetgroup
  engine                       = "aurora-mysql"
  engine_mode                  = "provisioned"
  engine_version               = var.aurora_mysql_engine_version
}

resource "aws_rds_cluster_instance" "mysql_cluster_instances" {
  count              = var.db_instances
  identifier         = "${var.project}-${var.environment}-mysql-${count.index}"
  cluster_identifier = aws_rds_cluster.mysql.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.mysql.engine
  engine_version     = aws_rds_cluster.mysql.engine_version
}

#RDS Parameters
resource "aws_ssm_parameter" "db_endpoint" {
  name        = "/${var.client}/${var.project}/${var.environment}/db_endpoint"
  description = "The ${var.project} - ${var.environment} Database Connection Endpoint"
  type        = "String"
  value       = aws_rds_cluster.mysql.endpoint
}
resource "aws_ssm_parameter" "db_ro_endpoint" {
  name        = "/${var.client}/${var.project}/${var.environment}/db_ro_endpoint"
  description = "The ${var.project} - ${var.environment} Database Connection Read Only Endpoint"
  type        = "String"
  value       = aws_rds_cluster.mysql.reader_endpoint
}

#RDS Security Group
resource "aws_security_group" "mysql_rds_sg" {
  name   = "${var.project}-${var.environment}-rds"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.project}-${var.environment}-rds"
  }
}

resource "aws_security_group_rule" "mysql_default_in" {
  security_group_id = aws_security_group.mysql_rds_sg.id
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "mysql_default_out" {
  security_group_id = aws_security_group.mysql_rds_sg.id
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  self              = true
}

#Security Group and Rules for  EKS cluster
resource "aws_security_group_rule" "eks_mysql_in" {
  security_group_id        = aws_security_group.mysql_rds_sg.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = var.node_sg
}

resource "aws_security_group_rule" "eks_mysql_out" {
  security_group_id        = aws_security_group.mysql_rds_sg.id
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = var.node_sg
}

resource "aws_security_group_rule" "mysql_eks_out" {
  security_group_id        = var.node_sg
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.mysql_rds_sg.id
}
