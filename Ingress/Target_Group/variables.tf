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
