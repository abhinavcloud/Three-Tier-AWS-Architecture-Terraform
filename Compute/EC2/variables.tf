#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

# Terraform Data Block - To Lookup Latest Ubuntu 20.04 AMI Image
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "Region" {
  description = "AWS Region Name"
  type        = string
}

variable "az_name_tag" {
  description = "Comma-separated list of Availability Zones"
  type        = string
}

variable "az_name" {
  description = "Comma-separated list of Availability Zones"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags for resources"
  type        = map(string)
}

variable "app_security_groups" {
  description = "Security Group IDs"
  type        = string
}

variable "web_security_groups" {
  description = "Security Group IDs"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string

}

variable "web_target_group_arn" {
  description = "ARN of the target group for the instances to register with"
  type        = string
}

variable "app_target_group_arn" {
  description = "ARN of the app target group for the instances to register with"
  type        = string
}


locals {
  merged_tags = merge(
    var.common_tags,
    {
      Region            = var.Region
      Name              = "ec2-${var.common_tags["Application"]}-${var.common_tags["Environment"]}-workspace-${terraform.workspace}"
      AvailabilityZones = var.az_name_tag
    }
  )
}

variable bucket_arn {
  description = "ARN of the S3 bucket"
  type        = string
}

variable vpc_endpoint_id {
  description = "VPC Endpoint ID for S3"
  type        = string
}

variable internal_alb_dns_name {
  description = "DNS name of the Internal ALB"
  type        = string
}

variable bucket_name {
  description = "Name of the S3 bucket"
  type        = string
}



variable bucket_id {
  description = "ID of the S3 bucket"
  type        = string
}