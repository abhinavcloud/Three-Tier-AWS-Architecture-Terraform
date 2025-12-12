Three-Tier AWS Architecture – Terraform

This repository contains the Terraform code for deploying a fully modular, environment-isolated three-tier architecture on AWS.

The application is a simple Task Manager that supports adding and listing daily tasks, stored in an S3 bucket via a VPC Endpoint.

Architecture Overview

                    ┌──────────────────────────────────┐
                    │              Internet            │
                    └──────────────────────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────────────┐
                    │      Public ALB (Public SG)      │
                    └──────────────────────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────────────┐
                    │   Web EC2 (Public Subnet, Web SG)│
                    └──────────────────────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────────────┐
                    │    Private ALB (Private ALB SG)  │
                    └──────────────────────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────────────┐
                    │  App EC2 (Private Subnet, App SG)│
                    └──────────────────────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────────────┐   
                    │         VPC Endpoint (S3)        |
                    └──────────────────────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────────────┐
                    │      S3 Bucket (tasks.json)      │
                    └──────────────────────────────────┘

Key Characteristics
- Strict isolation between public, web, and app layers.
- S3 is accessed only through the VPC Endpoint.
- No internet exposure for private tier.
- Environment versioning enabled via module pinning.
- Terraform state separation for Dev, Test, Staging, Prod.

Module Structure
1. Network -  VPC, Subnets (public/private), Route tables, VPC Endpoint configuration
2. Security - Security groups for ALBs, Web EC2, App EC2
3. Ingress - Public and Private ALB, Target Groups
4. Compute - EC2 (Web + App)
5. Storage - S3 bucket, Bucket policy


Environment Layout
Environments

 ├── Dev
 
 ├── Test
 
 ├── Staging
 
 └── Production

Each environment includes:

- Own variable definitions
  
- Dedicated remote state backend
  
- Pinned module versions
  
- Isolated deployment lifecycle


Application Flow

1. User accesses Public ALB.
2. Web EC2 serves frontend and forwards API calls to Private ALB.
3. App EC2 reads/writes tasks.json stored inside S3.
4. All S3 traffic stays inside VPC.

Deployment Steps
1. Naviagate to the specific environment folder -> cd Environment/Dev
2. Go through the init.sh, terraform.tfvars, terraform.tf, backend.hcl
3. Make the neccessary changes according to your cloud, state and secret provider
4. Make init.sh executable -> chmod +x init.sh
5. Run init.sh -> ./init.sh
6. Run -> terraform validate
7. Run -> terraform plan
8. Run -> terraform apply
9. Option, for infrastructre destruction, run -> terraform destroy

Final Output:
    Public ALB DNS Name for accessing the application


Project Structure
modules/

 ├── Compute/
 
      ├── EC2/
      
 ├── Ingress/
 
      ├── ALB/
      
      ├── Target_Group/
      
 ├── Network/
 
      ├── VPC/
      
      ├── Subnets/
      
      └── Route_tables/
      
 ├── Security_Groups/
 
 ├── Storage/
 
      └── S3/
      
 ├── Environments/
 
     ├── Dev/
     
     ├── Test/
     
     ├── Staging/
     
     └── Production/
 

Terraform Cloud Workspace Strategy (Can be implemented by the user)
1. Workspaces
    myapp-dev
    myapp-test
    myapp-staging
    myapp-prod
Each environment maps 1:1 with a workspace.

2. Variable Management
    - Environment variables (AMI IDs, instance sizes, CIDRs) stored in the 
       workspace.
    - Shared values stored in Variable Sets.
    - AWS credentials stored as workspace-level sensitive variables.

3. Module Versioning
Modules are connected to:
    Terraform Cloud Private Registry
    Each env pins a specific module version (example: vpc = "1.0.3")

4. Governance
    Sentinel policies for:
        - Mandatory tagging
        - No public S3
        - No 0.0.0.0/0 on sensitive SGs

5. CI/CD
    GitHub → Terraform Cloud webhook
    Every commit → terraform plan
    Prod requires manual apply
