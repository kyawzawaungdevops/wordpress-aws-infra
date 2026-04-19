locals {
  # Naming convention
  prefix = "${var.project_name}-${var.environment}"
}


module "network" {
  source = "./modules/network"

  prefix                = local.prefix
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  azs                   = var.azs
}

module "compute" {
  source = "./modules/compute"

  prefix     = local.prefix
  azs        = var.azs
  subnet_ids = module.network.private_subnet_ids
  vpc_id     = module.network.vpc_id
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  db_host     = module.rds.db_host
}

module "loadbalancer" {
  source       = "./modules/loadbalancer"
  prefix       = local.prefix
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.public_subnet_ids
  instance_ids = module.compute.instance_ids # ← from compute output
  target_port  = 80
  azs          = var.azs
}

module "rds" {
  source     = "./modules/rds"
  prefix     = local.prefix
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.database_subnet_ids # ← private subnets
  ec2_sg_id  = module.compute.ec2_sg_id      # ← only EC2 can reach RDS
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  multi_az                = true
  deletion_protection     = true
  backup_retention_period = 7
}