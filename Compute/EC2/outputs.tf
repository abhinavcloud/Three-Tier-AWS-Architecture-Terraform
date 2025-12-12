#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

output "app_asg_name" {
  value = aws_autoscaling_group.app_asg.name
}

output "web_asg_name" {
  value = aws_autoscaling_group.web_asg.name
}

output "app_launch_template_id" {
  value = aws_launch_template.app_launch_template.id
}

output "web_launch_template_id" {
  value = aws_launch_template.web_launch_template.id
}

output "app_desired_capacity" {
  value = aws_autoscaling_group.app_asg.desired_capacity
}

output "web_desired_capacity" {
  value = aws_autoscaling_group.web_asg.desired_capacity
}

output "app_min_capacity" {
  value = aws_autoscaling_group.app_asg.min_size
}

output "app_max_capacity" {
  value = aws_autoscaling_group.app_asg.max_size
}

output "web_min_capacity" {
  value = aws_autoscaling_group.web_asg.min_size
}

output "web_max_capacity" {
  value = aws_autoscaling_group.web_asg.max_size
}