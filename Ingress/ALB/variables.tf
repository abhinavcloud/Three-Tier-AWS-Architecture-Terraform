#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

variable "common_tags" {
  description = "Common tags for resources"
  type        = map(string)
}

variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable alb_security_group_id  {
  description = "Security Group ID for the ALB"
  type        = string
}    

variable web_target_group_arn {
  description = "ARN of the target group for the ALB listener"
  type        = string
}

variable app_target_group_arn {
  description = "ARN of the application target group"
  type        = string
}

variable private_alb_security_group_id  {
  description = "Security Group ID for the Private ALB"
  type        = string
} 