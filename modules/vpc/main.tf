###############################################################################
# VPC
###############################################################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.environment}-vpc"
  })
}

###############################################################################
# Internet Gateway (for public subnets only)
###############################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.environment}-igw"
  })
}

###############################################################################
# Subnets
###############################################################################

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.environment}-public-${var.availability_zones[count.index]}"
  })
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.environment}-private-${var.availability_zones[count.index]}"
  })
}

###############################################################################
# Route Tables
###############################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-public-rt"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.environment}-private-rt"
  })
}

resource "aws_route" "private_tgw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

###############################################################################
# Transit Gateway Attachment
###############################################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  vpc_id             = aws_vpc.this.id
  subnet_ids         = aws_subnet.private[*].id
  transit_gateway_id = var.transit_gateway_id

  tags = merge(var.tags, {
    Name = "${var.environment}-tgw-attachment"
  })
}

###############################################################################
# VPC Endpoints — Security Group
###############################################################################

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.environment}-vpc-endpoints"
  description = "Allow HTTPS from private subnets to VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-vpc-endpoints-sg"
  })
}

###############################################################################
# VPC Endpoints — Gateway (free)
###############################################################################

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = merge(var.tags, {
    Name = "${var.environment}-vpce-s3"
  })
}

###############################################################################
# VPC Endpoints — Interface (PrivateLink)
###############################################################################

locals {
  interface_endpoints = {
    ecr_api       = "com.amazonaws.${var.aws_region}.ecr.api"
    ecr_dkr       = "com.amazonaws.${var.aws_region}.ecr.dkr"
    logs          = "com.amazonaws.${var.aws_region}.logs"
    ecs           = "com.amazonaws.${var.aws_region}.ecs"
    ecs_agent     = "com.amazonaws.${var.aws_region}.ecs-agent"
    ecs_telemetry = "com.amazonaws.${var.aws_region}.ecs-telemetry"
    sts           = "com.amazonaws.${var.aws_region}.sts"
    ssm           = "com.amazonaws.${var.aws_region}.ssm"
    ssmmessages   = "com.amazonaws.${var.aws_region}.ssmmessages"
    ec2messages   = "com.amazonaws.${var.aws_region}.ec2messages"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id              = aws_vpc.this.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = merge(var.tags, {
    Name = "${var.environment}-vpce-${each.key}"
  })
}
