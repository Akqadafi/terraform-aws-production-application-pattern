locals {
  name_prefix = var.project_name

  tags = {
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

module "network" {
  source = "./modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  tags                 = local.tags
}

module "security" {
  source = "./modules/security"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
  my_ip_cidr  = var.my_ip_cidr
  tags        = local.tags
}

module "database" {
  source = "./modules/database"

  name_prefix          = local.name_prefix
  vpc_id               = module.network.vpc_id
  private_subnet_ids   = module.network.private_subnet_ids
  rds_security_group_id = module.security.rds_sg_id

  db_engine         = var.db_engine
  db_instance_class = var.db_instance_class
  storage_type      = var.storage_type
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password

  tags = local.tags
}

module "app_ec2" {
  source = "./modules/app_ec2"

  name_prefix            = local.name_prefix
  public_subnet_id       = module.network.public_subnet_ids[0]
  ec2_security_group_id  = module.security.ec2_sg_id
  ec2_instance_type      = var.ec2_instance_type

  # uses your same SSM AMI parameter name
  ami_ssm_parameter_name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"

  tags = local.tags
}

module "monitoring" {
  source = "./modules/monitoring"

  name_prefix         = local.name_prefix
  sns_email_endpoint  = var.sns_email_endpoint

  tags = local.tags
}

# # Optional endpoints module (skeleton right now)
# module "endpoints" {
#   source = "./modules/endpoints"
#   name_prefix        = local.name_prefix
#   vpc_id             = module.network.vpc_id
#   private_subnet_ids = module.network.private_subnet_ids
#   tags               = local.tags
# }