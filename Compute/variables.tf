#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

variable "common_tags" {
  description = "Common tags for resources"
  type        = map(string)
}

variable private_subnets {
  description = "Private subnet IDs"
  type        = list(string)
}

variable public_subnets {
  description = "Map of public subnet IDs"
  type        = list(string)
}   

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable instance_type {
  description = "EC2 Instance Type"
  type        = string
  
}

variable "allowed_ports" {
  description = "List of allowed ports"
  type        = list(number)
}

variable cidr_blocks {
  description = "List of CIDR blocks allowed to access"
  type        = list(string)
}

variable web_target_group_arn {
  description = "ARN of the target group for the instances to register with"
  type        = string
}

variable app_target_group_arn {
  description = "ARN of the app target group for the instances to register with"
  type        = string
}

variable alb_security_group_id {
  description = "Security Group ID of the ALB"
  type        = string
}

variable bucket_arn {
  description = "ARN of the S3 bucket"
  type        = string
}

variable vpc_endpoint_id {
  description = "VPC Endpoint ID for S3"
  type        = string
}

variable private_alb_security_group_id {
  description = "Security Group ID of the Private ALB"
  type        = string
}

variable vpc_cidr {
  description = "CIDR block of the VPC"
  type        = string
}

variable internal_alb_dns_name {
  description = "DNS name of the Internal ALB"
  type        = string
}

variable bucket_name {
  description = "Name of the S3 bucket"
  type        = string
}

variable bucket_id {
  description = "ID of the S3 bucket"
  type        = string
}

variable "app_security_groups" {
  description = "Security Group IDs"
  type        = string
}

variable "web_security_groups" {
  description = "Security Group IDs"
  type        = string
}
