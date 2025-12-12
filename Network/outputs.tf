#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

output "network_vpc_id" {
  description = "Output the ID for the primary VPC"
  value       = module.VPC.vpc_id
}

output "network_vpc_cidr" {
  description = "Output the ID for the primary VPC CIDR"
  value       = module.VPC.vpc_cidr
}

output internet_gateway_id {
  description = "Output the ID of the Internet Gateway"
  value       = module.Route_Tables.internet_gateway_id
}

output public_route_table_id {
  description = "Output the ID of the Public Route Table"
  value       = module.Route_Tables.public_route_table_id
}

output private_route_table_id {
  description = "Output the ID of the Private Route Table"
  value       = module.Route_Tables.private_route_table_id
}

output "private_subnets" {
  description = "Output the IDs of the private subnets"
  value       = module.Subnets.private_subnets
}

output "public_subnets" {
  description = "Output the IDs of the public subnets"
  value       = module.Subnets.public_subnets
}



output vpc_endpoint_id  {
  description = "Output the ID of the VPC Endpoint for S3"
  value       = module.Route_Tables.vpc_endpoint_id
}
