#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

variable "common_tags" {
  description = "Common tags for resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)  
  
}


variable cidr_blocks {
  description = "List of CIDR blocks allowed to access"
  type        = list(string)
}

variable alb_security_group_id {
  description = "Web ALB Security Group Id"
  type = string
}

variable private_alb_security_group_id {
  description = "Private ALB Security group id"
  type = string
}



