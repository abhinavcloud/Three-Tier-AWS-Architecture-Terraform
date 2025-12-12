#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

output "private_subnets" {
  description = "Output the IDs of the private subnets"
  value       = values(aws_subnet.private_subnets)[*].id
}

output "public_subnets" {
  description = "Output the IDs of the public subnets"
  value       = values(aws_subnet.public_subnets)[*].id
}





