#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

output bucket_arn {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.app_bucket.arn
}

output bucket_name {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.app_bucket.bucket
}

output bucket_url {
  description = "The URL of the S3 bucket"
  value       = aws_s3_bucket.app_bucket.bucket_regional_domain_name
}
output bucket_id {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.app_bucket.id
}
