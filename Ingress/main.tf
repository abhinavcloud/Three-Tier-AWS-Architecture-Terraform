#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

module ALB {
    source = "../Ingress/ALB"
    common_tags = var.common_tags
    public_subnets = var.public_subnets
    private_subnets = var.private_subnets
    alb_security_group_id = var.alb_security_group_id
    private_alb_security_group_id = var.private_alb_security_group_id
    web_target_group_arn =  module.Target_Group.web_target_group_arn
    app_target_group_arn = module.Target_Group.app_target_group_arn
}

module Target_Group {
    source = "../Ingress/Target_Group"
    common_tags = var.common_tags
    vpc_id = var.vpc_id
}




