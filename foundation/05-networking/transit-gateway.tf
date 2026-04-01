################################################################################
# Transit Gateway – deployed in Shared Services account
################################################################################

resource "aws_ec2_transit_gateway" "this" {
  provider = aws.shared_services

  description                     = "Landing Zone Transit Gateway"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"

  tags = {
    Name = "landing-zone-tgw"
  }
}

################################################################################
# RAM – share Transit Gateway with the entire Organization
################################################################################

resource "aws_ram_resource_share" "tgw" {
  provider = aws.shared_services

  name                      = "transit-gateway-share"
  allow_external_principals = false

  tags = {
    Name = "transit-gateway-share"
  }
}

resource "aws_ram_resource_association" "tgw" {
  provider = aws.shared_services

  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}

resource "aws_ram_principal_association" "org" {
  provider = aws.shared_services

  principal          = data.aws_organizations_organization.current.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}
