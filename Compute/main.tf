#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

# Data sources
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

module "EC2" {
  source      = "./EC2/"
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  web_security_groups = var.web_security_groups
  app_security_groups = var.app_security_groups
  instance_type = var.instance_type
  Region = data.aws_region.current.name
  az_name     = data.aws_availability_zones.available.names
  az_name_tag = join(",", data.aws_availability_zones.available.names)
  common_tags = var.common_tags
  web_target_group_arn = var.web_target_group_arn
  app_target_group_arn = var.app_target_group_arn
  bucket_arn = var.bucket_arn
  vpc_endpoint_id = var.vpc_endpoint_id
  internal_alb_dns_name = var.internal_alb_dns_name
  bucket_name = var.bucket_name
  bucket_id = var.bucket_id
}


