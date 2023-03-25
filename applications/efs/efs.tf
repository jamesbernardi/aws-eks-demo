locals {
  mounts = {
    for pair in setproduct(var.environments, var.efs_access_points) : "${pair[0]}-${pair[1]}" => {
      environments      = pair[0]
      efs_access_points = pair[1]
    }
  }
}

#Pull in data from Infra
data "aws_vpcs" "vpc" {
  tags = {
    Name = var.project
  }
}
data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["${var.project}-private-*"]
  }
}
data "aws_security_group" "efs" {
  filter {
    name   = "tag:Name"
    values = ["${var.project}-efs"]
  }
}

#CREATE EFS
resource "aws_efs_file_system" "application" {
  creation_token = "${var.project}-${var.name}"
  tags = {
    Name = "${var.project}-${var.name}"
  }
}

resource "aws_efs_mount_target" "application" {
  file_system_id = aws_efs_file_system.application.id

  for_each = toset(data.aws_subnets.private.ids)

  subnet_id = each.value

  security_groups = [data.aws_security_group.efs.id]
}

#CREATE EFS BACKUP POLICY
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.application.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_access_point" "access_point" {
  for_each       = local.mounts
  file_system_id = aws_efs_file_system.application.id
  root_directory {
    path = "/${each.key}"
    creation_info {
      owner_gid   = "1000"
      owner_uid   = "1000"
      permissions = "0777"
    }
  }
  tags = {
    Name = each.key
  }
}
