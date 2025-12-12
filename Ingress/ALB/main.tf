#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

# Create a resource block for to create a Public ALB 
resource "aws_lb" "application_lb" {
  name               = "lb-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnets

  tags = merge(
    var.common_tags,
    {       
      Name = "alb-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
    } 
  )
}

#Creating a Public HTTP Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.web_target_group_arn
  }
  tags = merge(
    var.common_tags,
    {       
      Name = "alb-listener-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
    } 
  )     

}

#Create a private alb for app target group using the private alb security group
resource "aws_lb" "private_application_lb" {
  name               = "pvt-lb-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-ws-${terraform.workspace}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.private_alb_security_group_id]
  subnets            = var.private_subnets  
  tags = merge(
    var.common_tags,
    {       
      Name = "private-alb-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
    } 
  )
}

#Create a Private ALB Listener
resource "aws_lb_listener" "private_http_listener" {
  load_balancer_arn = aws_lb.private_application_lb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.app_target_group_arn
  }
  tags = merge(
    var.common_tags,
    {       
      Name = "private-alb-listener-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
    } 
  )     

}



