#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

/* Only the Public Facing DNS Name is exposed as final output.
This is intentional.
It ouputs only what is required to access the application as an user.
The maintainers may chose to output other data if there is busines or technical need.
*/

output "Public_ALB_DNS_Name" {
  description = "Output the DNS name of the ALB"
  value       = "http://${module.Ingress.alb_dns_name}"
}





