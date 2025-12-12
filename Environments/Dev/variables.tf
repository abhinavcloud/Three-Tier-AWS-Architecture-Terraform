#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

/*
These variables are supplied from the route module and used everywhere via references and interpolation.
The values of these varaibles can be referenced from the choice maintainer makes on storing constants.
Some reccomended options may be:
- Terraform Cloud
- Terraform Vault
- AWS Secrets Manager
- Any other secret manager
*/

variable "Environment" {
  type = string

}

variable "Application" {
  type = string

}

variable "vpc_cidr" {
  type = string

}

variable "instance_type" {
  type = string
}

variable "allowed_ports" {
  description = "List of allowed ports"
  type        = list(number)
}

variable "cidr_blocks" {
  description = "List of CIDR blocks allowed to access"
  type        = list(string)
}

locals {
  common_tags = {
    Environment = var.Environment
    Application = var.Application
  }
}



 