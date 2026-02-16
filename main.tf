locals {
  name_prefix = var.project_name

  tags = {
    Project     = var.project_name
    Environment = var.env
    ManagedBy   = "terraform"
  }
}

# 1) Network
module "network" {
  source = "./modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = local.tags
}

# 2) Endpoints (SSM, logs, secrets, etc.)
module "endpoints" {
  source = "./modules/endpoints"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id

  private_subnet_ids = module.network.private_subnet_ids

  tags = local.tags
}

# 3) RDS + Secret
module "db" {
  source = "./modules/rds_secret"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id

  db_subnet_ids = module.network.private_subnet_ids

  db_engine         = var.db_engine
  db_instance_class = var.db_instance_class
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  storage_type      = var.storage_type

  tags = local.tags
}

# 4) EC2 + IAM (app host)
module "app" {
  source = "./modules/iam_ec2"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id

  subnet_id      = module.network.public_subnet_ids[0] # or private, depending on your design
  instance_type  = var.ec2_instance_type
  ami_ssm_param  = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
  my_ip_cidr     = var.my_ip_cidr

  # If your app needs DB connection info:
  db_endpoint = module.db.db_endpoint
  secret_arn  = module.db.secret_arn

  tags = local.tags
}

# 5) Monitoring + SNS
module "monitoring" {
  source = "./modules/monitoring"

  name_prefix        = local.name_prefix
  sns_email_endpoint = var.sns_email_endpoint

  # Wire alarms to instance if you do that:
  instance_id = module.app.instance_id

  tags = local.tags
}