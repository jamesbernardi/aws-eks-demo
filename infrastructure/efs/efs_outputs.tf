output "sg" {
  value = aws_security_group.efs.id
}

#DNS name is the same in all AZ's
output "mount_target" {
  value = aws_efs_mount_target.web_roots.0.dns_name
}
