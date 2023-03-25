output "target_group_arns" {
  value = module.nlb.target_group_arns
}
output "sg" {
  value = aws_security_group.nlb_sg.id
}
