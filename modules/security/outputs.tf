output "ec2_sg_id" { value = aws_security_group.arcanum_ec2_sg01.id }
output "rds_sg_id" { value = aws_security_group.arcanum_rds_sg01.id }