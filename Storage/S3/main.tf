#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

#Create a random id for S3 bucket to ensure unique bucket name
resource "random_id" "bucket_id" {
  byte_length = 4
}


#Resource block to create a S3 bucket with versioning enabled and private acess and only instamces in private subnet can access the bucket

resource "aws_s3_bucket" "app_bucket" {
  bucket = "app-bkt-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-${terraform.workspace}-${random_id.bucket_id.hex}"
  force_destroy = true # <-- allows terraform to delete bucket even if it has objects
    tags = merge(
           var.common_tags,
          {
            Name = "app-bucket-${var.common_tags["Environment"]}-${var.common_tags["Application"]}-${terraform.workspace}"
          }
        )   
        
   }
        

resource aws_s3_bucket_versioning "versioning" {
  bucket = aws_s3_bucket.app_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced" 
    # <-- ACL is disabled, AWS owner controls content. No need for `aws_s3_bucket_acl`.
  }
}

#Resource block to block public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.app_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on = [aws_s3_bucket_policy.restrict_to_vpc_endpoint]
}

#Resource block to enable server side encryption for S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_configuration" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Resource block to restrict access to S3 bucket only from VPC Endpoint   
resource aws_s3_bucket_policy "restrict_to_vpc_endpoint" {
  bucket = aws_s3_bucket.app_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowVPCeOnly"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.app_bucket.arn,
          "${aws_s3_bucket.app_bucket.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = var.vpc_endpoint_id
          }
        }
      }
    ]
  })    
}