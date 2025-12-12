#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

module S3 {
    source = "../Storage/S3"
    common_tags = var.common_tags
    vpc_endpoint_id = var.vpc_endpoint_id
}
