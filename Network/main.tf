#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

# Data sources
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

#Module Main
module "VPC" {
  source      = "./VPC/"
  Region = data.aws_region.current.name
  #region_name = data.aws_region.current.name
  az_name_tag = join(",", data.aws_availability_zones.available.names)
  common_tags = var.common_tags
  vpc_cidr    = var.vpc_cidr
}


module "Subnets" {
  source      = "./Subnets/"
  vpc_id      = module.VPC.vpc_id
  cidr_block  = module.VPC.vpc_cidr
  Region = data.aws_region.current.name
  az_name     = data.aws_availability_zones.available.names
  az_name_tag = join(",", data.aws_availability_zones.available.names)
  common_tags = var.common_tags

}

module "Route_Tables" {
  source      = "./Route_Tables/"
  vpc_id      = module.VPC.vpc_id
  cidr_block  = module.VPC.vpc_cidr
  private_subnets = module.Subnets.private_subnets
  public_subnets  = module.Subnets.public_subnets
  Region = data.aws_region.current.name
  az_name     = data.aws_availability_zones.available.names
  az_name_tag = join(",", data.aws_availability_zones.available.names)
  common_tags = var.common_tags
}