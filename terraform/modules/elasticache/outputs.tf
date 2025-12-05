output "redis_address" {
  description = "The primary endpoint address of the Redis cluster"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_sg_id" {
  description = "The ID of the Security Group for Redis"
  value       = aws_security_group.redis_sg.id
}
