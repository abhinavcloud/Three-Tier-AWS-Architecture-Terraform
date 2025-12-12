#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

output bucket_arn {
  description = "The ARN of the S3 bucket"
  value       = module.S3.bucket_arn
}

output bucket_name {
  description = "The name of the S3 bucket"
  value       = module.S3.bucket_name
}

output bucket_id {
  description = "The ID of the S3 bucket"
  value       = module.S3.bucket_id
}