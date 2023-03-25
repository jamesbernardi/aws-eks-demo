resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = var.name
  description                = var.replication_group_description
  num_cache_clusters         = 3
  node_type                  = var.redis_node_type
  automatic_failover_enabled = true
  multi_az_enabled           = true
  auto_minor_version_upgrade = true
  engine                     = "redis"
  engine_version             = var.redis_engine_version
  parameter_group_name       = var.redis_parameter_group
  port                       = 6379
  subnet_group_name          = var.elasticache_subnetgroup
  security_group_ids         = [aws_security_group.redis.id]

  lifecycle {
    create_before_destroy = false
  }
}

#Redis Parameters
resource "aws_ssm_parameter" "redis_endpoint" {
  name        = "/${var.client}/${var.project}/${var.environment}/redis_endpoint"
  description = "The ${var.project} - ${var.environment} Redis Connection Endpoint"
  type        = "String"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}
resource "aws_ssm_parameter" "redis_ro_endpoint" {
  name        = "/${var.client}/${var.project}/${var.environment}/redis_ro_endpoint"
  description = "The ${var.project} - ${var.environment} Redis Read Only Connection Endpoint"
  type        = "String"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

# redis default Security Group
resource "aws_security_group" "redis" {
  name   = "${var.project}-${var.environment}-redis"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.project}-${var.environment}-redis"
  }
}

resource "aws_security_group_rule" "redis_default_in" {
  security_group_id = aws_security_group.redis.id
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "redis_default_out" {
  security_group_id = aws_security_group.redis.id
  type              = "egress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  self              = true
}

#EKS Redis Security Groups
resource "aws_security_group_rule" "eks_redis_in" {
  security_group_id        = aws_security_group.redis.id
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = var.node_sg
}

resource "aws_security_group_rule" "eks_redis_out" {
  security_group_id        = aws_security_group.redis.id
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = var.node_sg
}

resource "aws_security_group_rule" "redis_eks_out" {
  security_group_id        = var.node_sg
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.redis.id
}
