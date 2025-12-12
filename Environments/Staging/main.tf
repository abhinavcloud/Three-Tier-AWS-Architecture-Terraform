#Created by: Abhinav Kumar (abhinav@abhinav-cloud.com)
#Version 1.0

/* Provider Block
The configuration uses AWS as the Terraform provider.
The AWS region is sourced from the local AWS config file using the default profile, rather than hardcoding it in the provider block.

Alternative ways to supply the region
- Define it directly inside the provider block: 
  region = "ap-south-1"

- When using Terraform Cloud, pass the region through environment variables such as:
  AWS_REGION, AWS_DEFAULT_REGION, or workspace variables.

This approach keeps configuration flexible and avoids embedding static values directly into code.
*/
provider "aws" {
  profile = "default"

}

/*Module Blocks
This configuration invokes modules sequentially using depends_on.
Although resources from one module are referenced inside another—which implicitly creates dependency links—we intentionally enforce explicit module-level dependencies.

Why explicitly use depends_on?
- To clearly define resource relationships and execution order.
- To avoid intermittent failures caused by indirect or unforeseen dependencies.
- To maintain tighter control over provisioning flow, especially during first-time infrastructure creation.
- To improve clarity for future maintainers by making dependencies visible at the module level.

Disclaimer: Module level depends_on reducess parallelism and introduces delay in infrastructure rollout.
But with tighter dependencies, environment reliablity is prioritised over speed.
This is a trade-off and you may modify or remove these dependencies based on your design preferences.
or if implicit references are sufficient for your use case.
*/

module "Network" {
  source      = "../../Network/"
  common_tags = local.common_tags
  vpc_cidr    = var.vpc_cidr

}

module "Security_Groups" {
  source        = "../../Security_Groups/"
  vpc_id        = module.Network.network_vpc_id
  allowed_ports = var.allowed_ports
  cidr_blocks   = var.cidr_blocks
  common_tags   = local.common_tags
  vpc_cidr      = var.vpc_cidr
  depends_on    = [module.Network]
}

module "Storage" {
  source          = "../../Storage/"
  common_tags     = local.common_tags
  vpc_endpoint_id = module.Network.vpc_endpoint_id
  depends_on      = [module.Security_Groups]
}

module "Ingress" {
  source                        = "../../Ingress/"
  public_subnets                = module.Network.public_subnets
  private_subnets               = module.Network.private_subnets
  cidr_blocks                   = var.cidr_blocks
  common_tags                   = local.common_tags
  vpc_id                        = module.Network.network_vpc_id
  alb_security_group_id         = module.Security_Groups.alb_security_group_id
  private_alb_security_group_id = module.Security_Groups.private_alb_security_group_id
  depends_on                    = [module.Storage]
}

module "Compute" {
  source                        = "../../Compute/"
  instance_type                 = var.instance_type
  private_subnets               = module.Network.private_subnets
  public_subnets                = module.Network.public_subnets
  vpc_id                        = module.Network.network_vpc_id
  vpc_cidr                      = var.vpc_cidr
  allowed_ports                 = var.allowed_ports
  cidr_blocks                   = var.cidr_blocks
  common_tags                   = local.common_tags
  web_target_group_arn          = module.Ingress.web_target_group_arn
  app_target_group_arn          = module.Ingress.app_target_group_arn
  web_security_groups           = module.Security_Groups.web_security_group_id
  app_security_groups           = module.Security_Groups.app_security_group_id
  alb_security_group_id         = module.Security_Groups.alb_security_group_id
  private_alb_security_group_id = module.Security_Groups.private_alb_security_group_id
  bucket_arn                    = module.Storage.bucket_arn
  vpc_endpoint_id               = module.Network.vpc_endpoint_id
  internal_alb_dns_name         = module.Ingress.internal_alb_dns_name
  bucket_name                   = module.Storage.bucket_name
  bucket_id                     = module.Storage.bucket_id
  depends_on                    = [module.Ingress]

}




