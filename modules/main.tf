resource "aws_vpc" "arcanum_vpc01" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc01"
  })
}

resource "aws_internet_gateway" "arcanum_igw01" {
  vpc_id = aws_vpc.arcanum_vpc01.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw01"
  })
}

resource "aws_subnet" "arcanum_public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.arcanum_vpc01.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-subnet0${count.index + 1}"
  })
}

resource "aws_subnet" "arcanum_private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.arcanum_vpc01.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-subnet0${count.index + 1}"
  })
}

resource "aws_eip" "arcanum_nat_eip01" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip01"
  })
}

resource "aws_nat_gateway" "arcanum_nat01" {
  allocation_id = aws_eip.arcanum_nat_eip01.id
  subnet_id     = aws_subnet.arcanum_public_subnets[0].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat01"
  })

  depends_on = [aws_internet_gateway.arcanum_igw01]
}

resource "aws_route_table" "arcanum_public_rt01" {
  vpc_id = aws_vpc.arcanum_vpc01.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt01"
  })
}

resource "aws_route" "arcanum_public_default_route" {
  route_table_id         = aws_route_table.arcanum_public_rt01.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.arcanum_igw01.id
}

resource "aws_route_table_association" "arcanum_public_rta" {
  count          = length(aws_subnet.arcanum_public_subnets)
  subnet_id      = aws_subnet.arcanum_public_subnets[count.index].id
  route_table_id = aws_route_table.arcanum_public_rt01.id
}

resource "aws_route_table" "arcanum_private_rt01" {
  vpc_id = aws_vpc.arcanum_vpc01.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-rt01"
  })
}

resource "aws_route" "arcanum_private_default_route" {
  route_table_id         = aws_route_table.arcanum_private_rt01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.arcanum_nat01.id
}

resource "aws_route_table_association" "arcanum_private_rta" {
  count          = length(aws_subnet.arcanum_private_subnets)
  subnet_id      = aws_subnet.arcanum_private_subnets[count.index].id
  route_table_id = aws_route_table.arcanum_private_rt01.id
}