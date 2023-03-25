output "sg" {
  value = aws_security_group.mysql_rds_sg.id
}

output "host_name" {
  value = aws_rds_cluster.mysql.reader_endpoint
}
