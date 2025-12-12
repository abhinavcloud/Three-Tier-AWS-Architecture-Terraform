#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

output "vpc_id" {
  description = "Output the ID for the primary VPC"
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  description = "Output the ID for the primary VPC CIDR"
  value = aws_vpc.vpc.cidr_block
}

