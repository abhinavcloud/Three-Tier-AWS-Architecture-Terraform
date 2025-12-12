#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

output alb_dns_name {
  description = "Output the DNS name of the ALB"
  value       = aws_lb.application_lb.dns_name
}

output internal_alb_dns_name {
  description = "Output the DNS name of the Internal ALB"
  value       = aws_lb.private_application_lb.dns_name
}