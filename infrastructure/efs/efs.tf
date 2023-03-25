#CREATE SG FOR EFS ACCESS AND RULES
resource "aws_security_group" "efs" {
  name   = "${var.project}-${var.environment}-efs"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.project}-${var.environment}-efs"
  }
}

resource "aws_security_group_rule" "efs_in" {
  security_group_id = aws_security_group.efs.id
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "efs_out" {
  security_group_id = aws_security_group.efs.id
  type              = "egress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  self              = true
}

#CREATE EFS
resource "aws_efs_file_system" "efs_web_roots" {
  creation_token = var.creation_token
  tags = {
    Name = var.name
  }
}

resource "aws_efs_mount_target" "web_roots" {
  file_system_id = aws_efs_file_system.efs_web_roots.id

  count = var.azs

  subnet_id = var.private_subnets[count.index]

  security_groups = [aws_security_group.efs.id]
}

#CREATE EFS BACKUP POLICY
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs_web_roots.id

  backup_policy {
    status = "ENABLED"
  }
}

#EFS Security Groups
resource "aws_security_group_rule" "eks_efs_in" {
  security_group_id        = aws_security_group.efs.id
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = var.node_sg
}

resource "aws_security_group_rule" "eks_efs_out" {
  security_group_id        = aws_security_group.efs.id
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = var.node_sg
}

resource "aws_security_group_rule" "efs_eks_out" {
  security_group_id        = var.node_sg
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.efs.id
}

#EFS Parameters
resource "aws_ssm_parameter" "efs_endpoint" {
  name        = "/${var.client}/${var.project}/${var.environment}/efs_endpoint"
  description = "The ${var.project} - ${var.environment} EFS Connection Endpoint"
  type        = "String"
  value       = aws_efs_mount_target.web_roots[0].dns_name
}
