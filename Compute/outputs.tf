#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

output "web_launch_template_id" {
  value = module.EC2.web_launch_template_id
} 

output "app_launch_template_id" {
  value = module.EC2.app_launch_template_id
} 



output "app_asg_name" {
  value = module.EC2.app_asg_name
}


output "app_desired_capacity" {
  value = module.EC2.app_desired_capacity
} 

output "app_min_capacity" {
  value = module.EC2.app_min_capacity
} 

output "app_max_capacity" {
  value = module.EC2.app_max_capacity
}


output "web_asg_name" {
  value = module.EC2.web_asg_name
}


output "web_desired_capacity" {
  value = module.EC2.web_desired_capacity
} 

output "web_min_capacity" {
  value = module.EC2.web_min_capacity
} 

output "web_max_capacity" {
  value = module.EC2.web_max_capacity
}
