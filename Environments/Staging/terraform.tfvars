#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

/* 
The terraform.tfvars is used to supply the static values througout the modules
However, this may introduce security issue if this exposes a public ip, credentials, secrets or other sensitive data.
The secure ways to supplies these variables are:

- Store them at Terraform Vault, AWS Secrets Manager or other supported providers.
  Access them inside modules using data blocks

- Store them at Terraform Cloud as workspace variables and supply them during infra rollout 

Disclaimer: This file in is original form doesn't not contain any sensitive data. 
The values are specific to the deployed infrastructure.
*/

Environment   = "StagEnv"
Application   = "StagApp"
vpc_cidr      = "10.1.0.0/16"
instance_type = "t2.micro"
allowed_ports = [22, 443]
cidr_blocks   = ["0.0.0.0/0"]


