#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

#Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.cidr_block, 8, each.value)
  availability_zone =  var.az_name[each.value]

     tags = merge(
    var.common_tags,
    {
    Name      = "${each.key}-workspace-${terraform.workspace}"
    Region = var.Region
    AvailabilityZones = var.az_name_tag
    } 
  )
}


#Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each          = var.public_subnets
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.cidr_block, 8, each.value + 100)
  availability_zone =  var.az_name[each.value]
  map_public_ip_on_launch = true
  
    tags = merge(
    var.common_tags,
    {
    Name      = "${each.key}-workspace-${terraform.workspace}"
    Region = var.Region
    AvailabilityZones = var.az_name_tag
    } 
  )

  
}


