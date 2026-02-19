output "vpc_id" { value = aws_vpc.arcanum_vpc01.id }
output "public_subnet_ids" { value = aws_subnet.arcanum_public_subnets[*].id }
output "private_subnet_ids" { value = aws_subnet.arcanum_private_subnets[*].id }
output "nat_gateway_id" { value = aws_nat_gateway.arcanum_nat01.id }