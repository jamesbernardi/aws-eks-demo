output "sg" {
  value = aws_security_group.redis.id
}

output "host_name" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}
