#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

#Create a resource Block for Target Group with health checks for unhealthy instances
resource "aws_lb_target_group" "web_target_group" {
  name     = "tg-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id 
    health_check {
        interval            = 30
        path                = "/health"
        port                = "80"
        protocol            = "HTTP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        matcher = "200"
    }   
    tags = merge(
    var.common_tags,
    {       
      Name = "tg-web-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
    } 
    )
}

#Create a target group for internal private ALB and instances in private subnet
resource "aws_lb_target_group" "app_target_group" {
  name     = "tg-app-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-ws${terraform.workspace}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id 
    health_check {
        interval            = 30
        path                = "/health"
        port                = "traffic-port"     
        protocol            = "HTTP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        matcher = "200"
    }   
    tags = merge(
    var.common_tags,
    {
      Name = "tg-app-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
    } 
    )
}    

    