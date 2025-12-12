#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

#Create a security Group for ALB to ingress traffic from internet
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
  description = "Security group for ALB allowing ingress traffic from internet"
  vpc_id      = var.vpc_id  
    ingress {
        description = "Allow HTTP traffic from internet"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = var.cidr_blocks
    }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks
    }
    lifecycle {
    create_before_destroy = true
    }

    tags = merge(
    var.common_tags,
    {       
      Name = "sg-weblb-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
    }
    )
}

#Security Group to allow SSH, HTTP, and HTTPS traffic in Public Subnet
resource "aws_security_group" "web_sg" {
  name        = "web-sg-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
  description = "Security group for web server allowing SSH, HTTP, and HTTPS"
  vpc_id      = var.vpc_id    
  
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.cidr_blocks
      description = "Allow Port ${ingress.value}"
    }
  }

  ingress {
    description = "Allow ICMP Traffic"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.cidr_blocks
  }
  #Creating ingress from public ALB security group
  ingress {
    description = "Allow HTTP traffic from Public ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]

  }
  
  
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    
  }
  
  lifecycle {
    create_before_destroy = true
  } 

  tags = merge(
    var.common_tags,
    {       
      Name = "web-sg-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
    } 
  )

} 


#Create a security group for Private ALB to allw ingress from Public Subnet EC2 instances
resource "aws_security_group" "private_alb_sg" {
  name        = "private-alb-sg-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
  description = "Security group for Private ALB allowing ingress traffic from Public Subnet EC2 instances"
  vpc_id      = var.vpc_id  
    /*
    ingress {
        description = "Allow HTTP traffic from Public Subnet EC2 instances"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        #cidr_blocks = var.cidr_blocks
        
    }
    */
    ingress {
        description = "Allow HTTP traffic from Web Security Group"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        security_groups = [aws_security_group.web_sg.id]
      }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks
    }
    lifecycle {
    create_before_destroy = true
    } 
    tags = merge(
    var.common_tags,
    {      
      Name = "sg-applb-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}-private"
    }
    )
    depends_on = [ aws_security_group.web_sg ]

    
}

#Security Group to allow only internal communication in Private Subnet
resource "aws_security_group" "app_sg" {
  name        = "app-sg-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
  description = "Security group for application server allowing internal communication"
  vpc_id      = var.vpc_id    
  #Creating ingress from private alb security group
  ingress {
    description = "Allow HTTP traffic from Private ALB"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.private_alb_sg.id]
  }
  
  depends_on = [ aws_security_group.private_alb_sg ]


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
      }
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    var.common_tags,
    {       
      Name = "app-sg-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-workspace-${terraform.workspace}"
    } 
  )
}





