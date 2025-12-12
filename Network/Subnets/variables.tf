#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

variable "private_subnets" {
  default = {
    "private_subnet_1" = 0
    "private_subnet_2" = 1
    "private_subnet_3" = 2
  }
}

variable "public_subnets" {
  default = {
    "public_subnet_1" = 0
    "public_subnet_2" = 1
    "public_subnet_3" = 2
  }
}

variable "Region" {
  description = "AWS Region Name"
  type        = string
}

variable "az_name_tag" {
  description = "Comma-separated list of Availability Zones"
  type        = string
}


variable "common_tags" {
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