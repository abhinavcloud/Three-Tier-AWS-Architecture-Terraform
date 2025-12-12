#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

terraform {
  required_version = ">= 1.13.0"
  /* 
  If your backend is local, then comment out the backend block
  
  If your backend is s3 bucket then initialise the s3 backend block 
  Comment the cloud backend
  Make changes to your backed configuration accordingly in the dev_backend.hcl
  
  If your backend is Terrform Cloud then initialise the cloud backend 
  Comment out the s3 backend
  Provide the required values for the TF Cloud Backend
  
  */

  backend "s3" {
  }

  /*
  cloud {
    organization = "value"
    workspaces = {
      name = "workspace"
    }

  }
  */
  
  required_providers {
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}