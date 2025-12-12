#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

output web_security_group_id {
  description = "Output the ID of the security group"
  value       = aws_security_group.web_sg.id
}


output app_security_group_id {
  description = "Output the ID of the security group"
  value       = aws_security_group.app_sg.id
}

output alb_security_group_id {
  description = "Output the ID of the ALB Security Group"
  value       = aws_security_group.alb_sg.id
}

output private_alb_security_group_id {
  description = "Output the ID of the Private ALB Security Group"
  value       = aws_security_group.private_alb_sg.id
}
