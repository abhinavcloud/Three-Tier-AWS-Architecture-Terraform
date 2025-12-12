#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

variable "common_tags" {
  description = "Common tags for resources"
  type        = map(string)
}

variable "vpc_endpoint_id" {
  description = "VPC Endpoint ID for S3"
  type        = string
}
