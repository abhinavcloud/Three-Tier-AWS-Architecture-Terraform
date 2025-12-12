#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

#Need this below output to get ALB DNS name and pass it to the dev environment outputs.tf
output alb_dns_name {
  description = "Output the DNS name of the ALB"
  value       = module.ALB.alb_dns_name
}

#Output the target group ARN to be referenced in the Public EC2 modules
output web_target_group_arn {
  description = "Output the ARN of the backend target group"
  value       = module.Target_Group.web_target_group_arn
}

#Output the target group ARN to be referenced in the Private EC2 modules
output app_target_group_arn {
  description = "Output the ARN of the application target group"
  value       = module.Target_Group.app_target_group_arn
}

output internal_alb_dns_name {
  description = "Output the DNS name of the Internal ALB"
  value       = module.ALB.internal_alb_dns_name
}






