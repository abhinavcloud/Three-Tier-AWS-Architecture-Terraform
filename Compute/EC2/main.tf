#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

# Terraform Data Block - To generate TLS Private Key
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "MyAWSKey.pem"
}

# Terraform Resource Block - To Create AWS Key Pair
resource "aws_key_pair" "generated" {
  key_name   = "MyAWSKey"
  public_key = tls_private_key.generated.public_key_openssh

  lifecycle {
    ignore_changes = [key_name]
  }
}

#Data block to reference the webserbver.sh.tpl in the user data
data "template_file" "web_user_data" {
  template = file("${path.module}/webserver_latest.sh.tpl")

  vars = {
    internal_alb_dns_name  = var.internal_alb_dns_name

  }
}


#Resource Block to create Launch Template in Public Subnets
resource "aws_launch_template" "web_launch_template" {
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated.key_name

  network_interfaces {
    associate_public_ip_address = true
    #subnet_id                   = var.public_subnets
    security_groups = [var.web_security_groups]
  }

  user_data = base64encode(data.template_file.web_user_data.rendered)


  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name              = "web-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
        AvailabilityZones = var.az_name_tag
      }
    )
  }
  lifecycle {
    create_before_destroy = true
  }
}

#Resource Block to create Auto Scaling Group in Public Subnets
resource "aws_autoscaling_group" "web_asg" {
  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.public_subnets
  min_size            = 2
  max_size            = 5
  desired_capacity    = 2
  target_group_arns   = [var.web_target_group_arn]
  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

#IAM Role to be applied in Lauch Template of Private Subnets to access specific s3 bucket
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  force_detach_policies = true

  tags = merge(
    var.common_tags,
    {       
      Name = "iam-role-ec2-s3-access-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
    } 
  )
}

#IAM Policy to allow access to specific S3 bucket
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_access_policy-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
  description = "IAM policy to allow EC2 instances to access specific S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject"
          
        ]
        Effect   = "Allow"    
        Resource = [
          var.bucket_arn,
          "${var.bucket_arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = var.vpc_endpoint_id
          }
        }   
      }
    ]
  })
  lifecycle {
    prevent_destroy = false
    create_before_destroy = false
  }
  
  tags = merge(
    var.common_tags,
    {       
      Name = "iam-policy-s3-access-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
    } 
  )
}

#Resource to attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
  
  lifecycle {
    create_before_destroy = false #ensure detach hapens before replace

  }
}

#Create an Instance Profile to be used in Launch Template
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
  role = aws_iam_role.ec2_s3_access_role.name
  
  tags = merge(
    var.common_tags,
    {       
      Name = "iam-instance-profile-ec2-s3-access-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
    } 
  )
}


#Data block to reference the template file for User Data from appserver_updated.sh.tpl
data "template_file" "app_user_data" {
  template = file("${path.module}/appserver_latest.sh.tpl")

  vars = {
    bucket_name           = var.bucket_name
    region                = var.Region
    
  }
}

#Resource Block to create Launch Template in Private Subnets
resource "aws_launch_template" "app_launch_template" {
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    #subnet_id                   = var.public_subnets
    security_groups = [var.app_security_groups]
  }

  user_data = base64encode(data.template_file.app_user_data.rendered)
  


  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name              = "app-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
        AvailabilityZones = var.az_name_tag
      }
    )
  }
  lifecycle {
    create_before_destroy = true
  }

  
}

#Resource Block to create Auto Scaling Group in Private Subnets

resource "aws_autoscaling_group" "app_asg" {
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.private_subnets
  min_size            = 2
  max_size            = 5
  desired_capacity    = 2
  target_group_arns   = [var.app_target_group_arn]
  health_check_grace_period = 120
  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}