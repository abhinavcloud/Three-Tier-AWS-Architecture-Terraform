#-------------------------------------------------------------------------------------------------------
#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

#This script should be run at the very begining to intialise the terraform environment and workspaces
#The init command can be chosen from the set provided below based on the choice of backend
#-------------------------------------------------------------------------------------------------------

#!/bin/bash
echo "Initializing Terraform for Dev environment..."
echo "-------------------------------------------------------"


#Local backend
echo "Intializing local backend with dev configuration."
#terraform init -migrate-state

#S3 remote backend
echo "Intializing remote s3 backend with dev configuration."
terraform init -backend-config=dev_backend.hcl -migrate-state

#Terraform cloud
echo "Intializing Terraform Cloud backend with dev configuration."
#terraform init -migrate-state

echo "Initialization complete."
echo "----------------------------------------"
echo "Creating dev workspace."
terraform workspace new dev
echo "Switched to 'dev' workspace."
terraform workspace show