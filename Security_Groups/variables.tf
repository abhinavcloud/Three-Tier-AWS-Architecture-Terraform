#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

variable "vpc_id" {
  description = "VPC ID"
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

variable "common_tags" {
  description = "Common tags for resources"
  type        = map(string)
}



variable vpc_cidr {
  description = "CIDR block of the VPC"
  type        = string
}

