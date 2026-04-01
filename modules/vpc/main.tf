###############################################################################
# VPC + Secondary CIDR
###############################################################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_primary
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.environment}-vpc"
  })
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.vpc_cidr_secondary
}

###############################################################################
# Internet Gateway
###############################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.environment}-igw"
  })
}

###############################################################################
# Subnets — TGW (/28 × 3 AZs)
###############################################################################

resource "aws_subnet" "tgw" {
  count = length(var.tgw_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.tgw_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.environment}-tgw-${var.availability_zones[count.index]}"
    Tier = "tgw"
  })
}

###############################################################################
# Subnets — Web ALB (/27 × 3 AZs, public)
###############################################################################

resource "aws_subnet" "web_alb" {
  count = length(var.web_alb_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.web_alb_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.environment}-web-alb-${var.availability_zones[count.index]}"
    Tier = "web"
  })
}

###############################################################################
# Subnets — Web NLB (/27 × 3 AZs, reserved)
###############################################################################

resource "aws_subnet" "web_nlb" {
  count = length(var.web_nlb_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.web_nlb_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.environment}-web-nlb-${var.availability_zones[count.index]}"
    Tier = "web"
  })
}

###############################################################################
# Subnets — App Endpoint (/27 × 3 AZs — VPC endpoints, EFS, bastion)
###############################################################################

resource "aws_subnet" "app_endpoint" {
  count = length(var.app_endpoint_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_endpoint_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary]

  tags = merge(var.tags, {
    Name = "${var.environment}-app-endpoint-${var.availability_zones[count.index]}"
    Tier = "app"
  })
}

###############################################################################
# Subnets — App Compute (/23 × 3 AZs — ECS/EKS tasks)
###############################################################################

resource "aws_subnet" "app_compute" {
  count = length(var.app_compute_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_compute_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary]

  tags = merge(var.tags, {
    Name = "${var.environment}-app-compute-${var.availability_zones[count.index]}"
    Tier = "app"
  })
}

###############################################################################
# Subnets — Data (/27 × 3 AZs — RDS, reserved)
###############################################################################

resource "aws_subnet" "data" {
  count = length(var.data_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.data_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary]

  tags = merge(var.tags, {
    Name = "${var.environment}-data-${var.availability_zones[count.index]}"
    Tier = "data"
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

resource "aws_route_table" "tgw" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.environment}-tgw-rt"
  })
}

resource "aws_route" "tgw_to_tgw" {
  route_table_id         = aws_route_table.tgw.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.transit_gateway_id
}

###############################################################################
# Route Table Associations
###############################################################################

resource "aws_route_table_association" "web_alb" {
  count          = length(var.web_alb_subnet_cidrs)
  subnet_id      = aws_subnet.web_alb[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "web_nlb" {
  count          = length(var.web_nlb_subnet_cidrs)
  subnet_id      = aws_subnet.web_nlb[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "tgw" {
  count          = length(var.tgw_subnet_cidrs)
  subnet_id      = aws_subnet.tgw[count.index].id
  route_table_id = aws_route_table.tgw.id
}

resource "aws_route_table_association" "app_endpoint" {
  count          = length(var.app_endpoint_subnet_cidrs)
  subnet_id      = aws_subnet.app_endpoint[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "app_compute" {
  count          = length(var.app_compute_subnet_cidrs)
  subnet_id      = aws_subnet.app_compute[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "data" {
  count          = length(var.data_subnet_cidrs)
  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.private.id
}

###############################################################################
# Transit Gateway Attachment (TGW subnets only)
###############################################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  vpc_id             = aws_vpc.this.id
  subnet_ids         = aws_subnet.tgw[*].id
  transit_gateway_id = var.transit_gateway_id

  tags = merge(var.tags, {
    Name = "${var.environment}-tgw-attachment"
  })
}

###############################################################################
# NACLs — TGW
###############################################################################

resource "aws_network_acl" "tgw" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.tgw[*].id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "10.0.0.0/8"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "10.0.0.0/8"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-tgw-nacl"
  })
}

###############################################################################
# NACLs — Web ALB
###############################################################################

resource "aws_network_acl" "web_alb" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.web_alb[*].id

  # Inbound HTTP from internet
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Inbound HTTPS from internet
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Inbound ephemeral from VPC (return traffic from app tier)
  ingress {
    rule_no    = 200
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr_primary
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    rule_no    = 210
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr_secondary
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound to app compute subnets on container port
  dynamic "egress" {
    for_each = var.app_compute_subnet_cidrs
    content {
      rule_no    = 100 + egress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 80
      to_port    = 80
    }
  }

  # Outbound ephemeral to internet (return traffic)
  egress {
    rule_no    = 200
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-web-alb-nacl"
  })
}

###############################################################################
# NACLs — Web NLB (reserved, permissive)
###############################################################################

resource "aws_network_acl" "web_nlb" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.web_nlb[*].id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-web-nlb-nacl"
  })
}

###############################################################################
# NACLs — App Endpoint
###############################################################################

resource "aws_network_acl" "app_endpoint" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.app_endpoint[*].id

  # Inbound HTTPS from app compute (VPC endpoint traffic)
  dynamic "ingress" {
    for_each = var.app_compute_subnet_cidrs
    content {
      rule_no    = 100 + ingress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 443
      to_port    = 443
    }
  }

  # Inbound HTTPS from VPC CIDRs (other services reaching endpoints)
  ingress {
    rule_no    = 200
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr_primary
    from_port  = 443
    to_port    = 443
  }

  ingress {
    rule_no    = 210
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr_secondary
    from_port  = 443
    to_port    = 443
  }

  # Outbound ephemeral to app compute (return traffic)
  dynamic "egress" {
    for_each = var.app_compute_subnet_cidrs
    content {
      rule_no    = 100 + egress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 1024
      to_port    = 65535
    }
  }

  # Outbound ephemeral to VPC CIDRs
  egress {
    rule_no    = 200
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr_primary
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 210
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr_secondary
    from_port  = 1024
    to_port    = 65535
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-app-endpoint-nacl"
  })
}

###############################################################################
# NACLs — App Compute
###############################################################################

resource "aws_network_acl" "app_compute" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.app_compute[*].id

  # Inbound container port from web ALB subnets
  dynamic "ingress" {
    for_each = var.web_alb_subnet_cidrs
    content {
      rule_no    = 100 + ingress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 80
      to_port    = 80
    }
  }

  # Inbound ephemeral from app endpoint subnets (VPC endpoint return traffic)
  dynamic "ingress" {
    for_each = var.app_endpoint_subnet_cidrs
    content {
      rule_no    = 200 + ingress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 1024
      to_port    = 65535
    }
  }

  # Inbound ephemeral from data subnets (DB return traffic)
  dynamic "ingress" {
    for_each = var.data_subnet_cidrs
    content {
      rule_no    = 300 + ingress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 1024
      to_port    = 65535
    }
  }

  # Outbound to app endpoint subnets on 443 (VPC endpoints)
  dynamic "egress" {
    for_each = var.app_endpoint_subnet_cidrs
    content {
      rule_no    = 100 + egress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 443
      to_port    = 443
    }
  }

  # Outbound to data subnets on DB ports
  dynamic "egress" {
    for_each = var.data_subnet_cidrs
    content {
      rule_no    = 200 + egress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 3306
      to_port    = 3306
    }
  }

  dynamic "egress" {
    for_each = var.data_subnet_cidrs
    content {
      rule_no    = 300 + egress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 5432
      to_port    = 5432
    }
  }

  # Outbound ephemeral to web ALB subnets (return traffic)
  dynamic "egress" {
    for_each = var.web_alb_subnet_cidrs
    content {
      rule_no    = 400 + egress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 1024
      to_port    = 65535
    }
  }

  # Inbound ephemeral from VPC CIDR (DNS response + other return traffic)
  ingress {
    rule_no    = 400
    protocol   = "udp"
    action     = "allow"
    cidr_block = var.vpc_cidr_primary
    from_port  = 1024
    to_port    = 65535
  }

  # Inbound ephemeral from S3 gateway endpoint (public S3 IPs via route table)
  ingress {
    rule_no    = 410
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound HTTPS to S3 gateway endpoint (public S3 IPs via route table)
  egress {
    rule_no    = 450
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Outbound DNS to VPC resolver
  egress {
    rule_no    = 500
    protocol   = "udp"
    action     = "allow"
    cidr_block = var.vpc_cidr_primary
    from_port  = 53
    to_port    = 53
  }

  # Outbound DNS ephemeral return (TCP, for large DNS responses)
  egress {
    rule_no    = 510
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr_primary
    from_port  = 53
    to_port    = 53
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-app-compute-nacl"
  })
}

###############################################################################
# NACLs — Data
###############################################################################

resource "aws_network_acl" "data" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.data[*].id

  # Inbound MySQL from app compute
  dynamic "ingress" {
    for_each = var.app_compute_subnet_cidrs
    content {
      rule_no    = 100 + ingress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 3306
      to_port    = 3306
    }
  }

  # Inbound PostgreSQL from app compute
  dynamic "ingress" {
    for_each = var.app_compute_subnet_cidrs
    content {
      rule_no    = 200 + ingress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 5432
      to_port    = 5432
    }
  }

  # Outbound ephemeral to app compute (return traffic)
  dynamic "egress" {
    for_each = var.app_compute_subnet_cidrs
    content {
      rule_no    = 100 + egress.key
      protocol   = "tcp"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 1024
      to_port    = 65535
    }
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-data-nacl"
  })
}

###############################################################################
# VPC Endpoints — Security Group
###############################################################################

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.environment}-vpc-endpoints"
  description = "Allow HTTPS from app subnets to VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from app compute"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.app_compute_subnet_cidrs
  }

  ingress {
    description = "HTTPS from app endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.app_endpoint_subnet_cidrs
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
# VPC Endpoints — Interface (PrivateLink, in app endpoint subnets)
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
    # SSM endpoints omitted from demo (add for EC2 bastion/patching):
    # ssm         = "com.amazonaws.${var.aws_region}.ssm"
    # ssmmessages = "com.amazonaws.${var.aws_region}.ssmmessages"
    # ec2messages = "com.amazonaws.${var.aws_region}.ec2messages"
  }

  # Only place endpoints in the AZs where compute runs
  endpoint_subnet_ids = slice(aws_subnet.app_endpoint[*].id, 0, var.compute_az_count)
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id              = aws_vpc.this.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = local.endpoint_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = merge(var.tags, {
    Name = "${var.environment}-vpce-${each.key}"
  })
}
