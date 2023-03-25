###
##NLB SG's to Private IP's
resource "aws_security_group" "nlb_sg" {
  name   = "${var.name}_nlb_sg"
  vpc_id = var.vpc_id
}
#Add rules to nlb-sg
resource "aws_security_group_rule" "nlb-8443-in" {
  security_group_id = aws_security_group.nlb_sg.id
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr, "0.0.0.0/0"]
  ipv6_cidr_blocks  = [var.vpc_ipv6_cidr, "::/0"]
}
resource "aws_security_group_rule" "nlb-8443-out" {
  security_group_id = aws_security_group.nlb_sg.id
  type              = "egress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  ipv6_cidr_blocks  = [var.vpc_ipv6_cidr]
}
resource "aws_security_group_rule" "nlb-8000-in" {
  security_group_id = aws_security_group.nlb_sg.id
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr, "0.0.0.0/0"]
  ipv6_cidr_blocks  = [var.vpc_ipv6_cidr, "::/0"]
}
resource "aws_security_group_rule" "nlb-8000-out" {
  security_group_id = aws_security_group.nlb_sg.id
  type              = "egress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  ipv6_cidr_blocks  = [var.vpc_ipv6_cidr]
}
