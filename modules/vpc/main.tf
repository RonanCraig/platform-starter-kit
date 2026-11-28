resource "aws_vpc" "this" {
  # checkov:skip=CKV2_AWS_11:Flow logs bill CloudWatch ingestion; planned as an optional enable_flow_logs variable
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-vpc"
  }
}

data "aws_availability_zones" "available" {
  # checkov:skip=CKV_AWS_394:slice() below takes the first az_count zones, so a newly added AZ doesn't change the result
  state = "available"
}

locals {
  azs        = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  az_indexes = { for i, az in local.azs : az => i }
}

resource "aws_subnet" "public" {
  for_each                = local.az_indexes
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 1)
  availability_zone       = each.key
  map_public_ip_on_launch = true # checkov:skip=CKV_AWS_130:Public subnets assign public IPs by design
  tags = {
    Name = "${var.name}-public-${each.value + 1}"
  }
}

resource "aws_subnet" "private" {
  for_each          = local.az_indexes
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value + 11)
  availability_zone = each.key
  tags = {
    Name = "${var.name}-private-${each.value + 1}"
  }
}

# Takes over the VPC's default security group and removes all its rules,
# so anything accidentally launched without a security group gets no traffic.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-default-sg-locked"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags = {
    Name = "${var.name}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[local.azs[0]].id
  depends_on    = [aws_internet_gateway.this]
  tags = {
    Name = "${var.name}-nat-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route" "private" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-private-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}