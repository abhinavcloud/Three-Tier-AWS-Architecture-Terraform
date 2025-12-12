#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

#Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.internet_gateway.id
    #nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

    tags = merge(
    var.common_tags,
    {
    Name      = "demo_public_rtb-workspace-${terraform.workspace}"
    Region = var.Region
    AvailabilityZones = var.az_name_tag
    } 
  )

 }

resource "aws_route_table" "private_route_table" {

  for_each = local.private_subnet_map
  vpc_id = var.vpc_id
  depends_on = [ aws_nat_gateway.nat_gateway ]

  
  tags = merge(
    var.common_tags,
    {
    Name      = "demo_private_rtb-workspace-${terraform.workspace}"
    Region = var.Region
    AvailabilityZones = var.az_name_tag
    } 
  )
}

#Create routes for private route tables to point to NAT Gateway
resource "aws_route" "private_nat_route" {
  for_each = local.private_subnet_map 
  route_table_id         = aws_route_table.private_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id        = aws_nat_gateway.nat_gateway[each.key].id
  depends_on = [aws_nat_gateway.nat_gateway]
}


#Create route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [var.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = local.public_subnet_map
  subnet_id      = each.value
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnet_map

  depends_on     = [var.private_subnets]
  route_table_id = aws_route_table.private_route_table[each.key].id
  #for_each       = toset(var.private_subnets)
  subnet_id      = each.value
}

#Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = var.vpc_id
   tags = merge(
    var.common_tags,
    {
    Name = "demo_igw-workspace-${terraform.workspace}"
    Region = var.Region
    AvailabilityZones = var.az_name_tag
    } 
  )

}

#Create VPC Endpoint for S3 bucket
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.Region}.s3"
  vpc_endpoint_type = "Gateway"
  #route_table_ids   = [for rt in aws_route_table.private_route_table : rt.id]
  tags = merge(
    var.common_tags,
    {
    Name = "vpc-endpoint-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-${terraform.workspace}"
    } 
  )
}

#Attach VPC Endpoint to all private route tables
resource "aws_vpc_endpoint_route_table_association" "s3_endpoint_association" {
  for_each = local.private_subnet_map

  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
  route_table_id  = aws_route_table.private_route_table[each.key].id
}

#Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  #domain     = "vpc"
  #vpc = true
  depends_on = [aws_internet_gateway.internet_gateway]
  for_each   = local.public_subnet_map
  tags = merge(
    var.common_tags,
    {
    Name = "nat-gateway-eip-${each.key}-${terraform.workspace}"
    Region = var.Region
    AvailabilityZones = var.az_name_tag
    } 
  )
}

#Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [var.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip[each.key].id
  for_each       = local.public_subnet_map
  subnet_id      = each.value
  #subnet_id     = var.public_subnets["public_subnet_1"]
  tags = merge(
    var.common_tags,
    {
    Name = "demo_nat_gateway-workspace-${terraform.workspace}"
    Region = var.Region
    AvailabilityZones = var.az_name_tag
    } 
  )
  
}




