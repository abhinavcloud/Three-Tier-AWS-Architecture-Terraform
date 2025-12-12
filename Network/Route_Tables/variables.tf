#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

variable "az_name_tag" {
  description = "Comma-separated list of Availability Zones"
  type        = string
}


variable common_tags {
  description = "Common tags for resources"
  type        = map(string)
} 



variable "az_name" {
  description = "Comma-separated list of Availability Zones"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where subnets will be created"
  type        = string
}

variable "cidr_block" {
  description = "CIDR Block of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

locals {
  public_subnet_map = {
    for index, subnet in var.public_subnets : index => subnet   
  }
  private_subnet_map = {
    for index, subnet in var.private_subnets : index => subnet   
  }
}



variable "Region" {
  description = "AWS Region Name"
  type        = string
}