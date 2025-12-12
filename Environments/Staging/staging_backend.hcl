bucket         = "terraform-state-files-abhinav"
key            = "environments/staging/terraform.tfstate"
region         = "ap-south-1"
dynamodb_table = "my-terraform-lock-table"
encrypt        = true