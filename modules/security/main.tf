locals {
  ports_http      = 80
  ports_ssh       = 22
  db_port         = 3306
  tcp_protocol    = "tcp"
  all_ip_address  = "0.0.0.0/0"
  all_protocol    = "-1"
}

resource "aws_security_group" "arcanum_ec2_sg01" {
  name        = "${var.name_prefix}-ec2-sg01"
  description = "EC2 app security group"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2-sg01"
  })
}

resource "aws_vpc_security_group_ingress_rule" "arcanum_ec2_sg_ingress_http" {
  ip_protocol       = local.tcp_protocol
  security_group_id = aws_security_group.arcanum_ec2_sg01.id
  from_port         = local.ports_http
  to_port           = local.ports_http
  cidr_ipv4         = local.all_ip_address
}

# Your SSH rule is commented in the original. Here it is active (you can comment it if needed).
resource "aws_vpc_security_group_ingress_rule" "arcanum_ec2_sg_ingress_ssh" {
  ip_protocol       = local.tcp_protocol
  security_group_id = aws_security_group.arcanum_ec2_sg01.id
  from_port         = local.ports_ssh
  to_port           = local.ports_ssh
  cidr_ipv4         = var.my_ip_cidr
}

resource "aws_vpc_security_group_egress_rule" "arcanum_ec2_sg_egress_all" {
  ip_protocol       = local.all_protocol
  security_group_id = aws_security_group.arcanum_ec2_sg01.id
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = local.all_ip_address
}

resource "aws_security_group" "arcanum_rds_sg01" {
  name        = "${var.name_prefix}-rds-sg01"
  description = "RDS security group"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds-sg01"
  })
}

resource "aws_vpc_security_group_ingress_rule" "arcanum_rds_sg_ingress_mysql" {
  ip_protocol                  = local.tcp_protocol
  security_group_id            = aws_security_group.arcanum_rds_sg01.id
  from_port                    = local.db_port
  to_port                      = local.db_port
  referenced_security_group_id = aws_security_group.arcanum_ec2_sg01.id
}

resource "aws_vpc_security_group_egress_rule" "arcanum_rds_sg_egress_all" {
  ip_protocol       = local.all_protocol
  security_group_id = aws_security_group.arcanum_rds_sg01.id
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = local.all_ip_address
}