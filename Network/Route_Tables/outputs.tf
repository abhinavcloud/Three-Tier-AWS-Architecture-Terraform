#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

output internet_gateway_id {
  description = "Output the ID of the Internet Gateway"
  value       = aws_internet_gateway.internet_gateway.id
}

output public_route_table_id {
  description = "Output the ID of the Public Route Table"
  value       = aws_route_table.public_route_table.id
}

output private_route_table_id {
  description = "Output the ID of the Private Route Table"
  value       = {for k, v in aws_route_table.private_route_table : k => v.id }
}



output vpc_endpoint_id {
  description = "Output the ID of the VPC Endpoint for S3"
  value       = aws_vpc_endpoint.s3_endpoint.id
}