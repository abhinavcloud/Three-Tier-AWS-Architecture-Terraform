#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

#Output the target group ARN to be referenced in the 
#ALB listener resource and EC2 modules
output web_target_group_arn {
  description = "Output the ARN of the backend target group"
  value       = aws_lb_target_group.web_target_group.arn
}

output app_target_group_arn {
  description = "Output the ARN of the application target group"
  value       = aws_lb_target_group.app_target_group.arn
}