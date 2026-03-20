# Three-Tier AWS Architecture – Terraform

This repository contains the Terraform code for deploying a fully modular, environment-isolated three-tier architecture on AWS.

The application is a simple Task Manager that supports adding and listing daily tasks, stored in an S3 bucket via a VPC Endpoint.

## Architecture Overview

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

## Key Characteristics
- Strict isolation between public, web, and app layers.
- S3 is accessed only through the VPC Endpoint.
- No internet exposure for private tier.
- Environment versioning enabled via module pinning.
- Terraform state separation for Dev, Test, Staging, Prod.

## Module Structure
- Network -  VPC, Subnets (public/private), Route tables, VPC Endpoint configuration
- Security - Security groups for ALBs, Web EC2, App EC2
- Ingress - Public and Private ALB, Target Groups
- Compute - EC2 (Web + App)
- Storage - S3 bucket, Bucket policy


## Environment Layout
Environments

 ├── Dev
 
 ├── Test
 
 ├── Staging
 
 └── Production

# Each environment includes:

- Own variable definitions
  
- Dedicated remote state backend
  
- Pinned module versions
  
- Isolated deployment lifecycle


## Application Flow

- 1. User accesses Public ALB.
- 2. Web EC2 serves frontend and forwards API calls to Private ALB.
- 3. App EC2 reads/writes tasks.json stored inside S3.
- 4. All S3 traffic stays inside VPC.

## Deployment Steps
- 1. Naviagate to the specific environment folder -> cd Environment/Dev
- 2. Go through the init.sh, terraform.tfvars, terraform.tf, backend.hcl
- 3. Make the neccessary changes according to your cloud, state and secret provider
- 4. Make init.sh executable -> chmod +x init.sh
- 5. Run init.sh -> ./init.sh
- 6. Run -> terraform validate
- 7. Run -> terraform plan
- 8. Run -> terraform apply
- 9. Option, for infrastructre destruction, run -> terraform destroy

## Final Output:
    Public ALB DNS Name for accessing the application


## Project Structure
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
 

## CI/CD Pipeline Strategy
### Intent
This repository implements a controlled, drift-aware, multi-environment deployment pipeline for provisioning an AWS Three-Tier Architecture using Terraform. The goal is to ensure infrastructure consistency, prevent unintended changes, enforce safe promotion-based deployments, and maintain full auditability.

### Strategy Overview
The pipeline follows a strict environment promotion model:
Dev → Test → Staging → Production

Dev is the only environment triggered by direct code changes (push to master, excluding other environment paths) or manual execution. All higher environments (Test, Staging, Production) are triggered via workflow_run from the previous stage and only proceed if the prior environment completes successfully. Each promotion uses the same commit SHA, ensuring immutability and eliminating inconsistencies across environments.

### Drift-First Approach
Every deployment begins with a Terraform drift check using:
terraform plan -refresh-only -detailed-exitcode

Exit codes are interpreted as:
- 0: No drift → Safe to proceed
- 2: Drift detected → Deployment blocked and GitHub issue created
- 1: Error → Pipeline fails

Drift is intentionally treated as an incident and is not auto-corrected. This forces explicit review and prevents overwriting unknown or manual changes.

### Controlled Apply Execution
Terraform apply is executed only when:
- Drift check returns no drift (exit code 0)
- Execution context is valid (manual trigger or valid promotion)

This ensures no blind applies and no unintended reconciliation of infrastructure.

### Reusable Workflow Design
All Terraform operations are abstracted into reusable workflows:
- Drift Check
- Plan and Apply
- State List
- Destroy

This design ensures consistency, reduces duplication, and simplifies maintenance across environments.

### Observability and Auditability
Each pipeline execution generates artifacts:
- Drift plan output (drift-tfplan.md)
- Terraform plan output (tfplan.txt)
- State snapshot (state-file.txt)

Additionally, drift detection automatically creates GitHub issues. This provides full traceability, auditability, and easier debugging of infrastructure changes.

### Manual Operational Controls
Manual workflows are provided for critical operations:
- Terraform Destroy requires explicit confirmation ("DESTROY") and captures state before execution
- Terraform State List allows safe inspection without modifying infrastructure

These controls prevent accidental destructive actions and maintain operational safety.

### Security Model
Authentication to AWS is handled via OIDC, eliminating the need for static credentials. Access is controlled using GitHub environments, secrets, and environment-specific variables, ensuring least privilege and improved security posture.

### Concurrency Control
Each environment is protected with concurrency groups (e.g., terraform-dev, terraform-test, terraform-staging, terraform-production) to prevent overlapping executions and ensure deployment stability.

### Key Design Principles
- Drift blocks deployment instead of being auto-fixed, preventing hidden risks
- Promotion uses workflow_run with commit SHA to guarantee identical infrastructure across environments
- Only Dev allows direct changes; higher environments enforce strict promotion discipline

### Summary
This pipeline is a controlled infrastructure delivery system designed for safety and reliability. It enforces drift awareness, promotion-based deployments, modular design, full auditability, and safe execution practices by default.
