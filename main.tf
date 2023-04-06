provider "aws" {
  region  = var.region
  profile = var.environment
}

module "vpc_setup" {
  source = "./modules/vpcCreate"

  cidr_block            = var.vpc_cidr_block
  instance_tenancy      = var.vpc_instance_tenancy
  subnet_count          = var.subnet_count
  bits                  = var.subnet_bits
  vpc_name              = var.vpc_name
  internet_gateway_name = var.vpc_internet_gateway_name
  public_subnet_name    = var.vpc_public_subnet_name
  public_rt_name        = var.vpc_public_rt_name
  private_subnet_name   = var.vpc_private_subnet_name
  private_rt_name       = var.vpc_private_rt_name
}

module "sec_group_setup" {
  source = "./modules/securityGroupCreate"

  vpc_id   = module.vpc_setup.vpc_id
  app_port = var.app_port
  sec_group_id_lb = module.loadbalancer.sec_group_id_lb
}

module "db_sec_group_setup" {
  source = "./modules/dbSecurityGroupCreate"

  vpc_id     = module.vpc_setup.vpc_id
  secGroupId = module.sec_group_setup.sec_group_id
}

module "rds_instance" {
  source = "./modules/dbInstance"

  username           = var.username
  password           = var.password
  engine_version     = var.engine_version
  identifier         = var.identifier
  private_subnet_ids = module.vpc_setup.private_subnet_ids
  security_group_id  = module.db_sec_group_setup.db_sec_group_id
  db_name            = var.db_name
}

module "iam_role_setup" {
  source = "./modules/iamRoleCreate"

  s3_bucket = module.s3_bucket.s3_bucket
}

module "s3_bucket" {
  source = "./modules/s3BucketCreate"

  environment = var.environment
}

module "instance_create" {
  source = "./modules/ec2InstanceCreate"

  sec_id                             = module.sec_group_setup.sec_group_id
  ami_key_pair_name                  = var.ami_key_pair_name
  subnet_count                       = var.subnet_count
  subnet_ids                         = module.vpc_setup.subnet_ids
  volume_size                        = var.volume_size
  instance_type                      = var.instance_type
  volume_type                        = var.volume_type
  db_name                            = var.db_name
  username                           = var.username
  password                           = var.password
  host_name                          = module.rds_instance.host_name
  app_port                           = var.app_port
  db_port                            = var.db_port
  ec2_profile_name                   = module.iam_role_setup.ec2_profile_name
  s3_bucket                          = module.s3_bucket.s3_bucket
  zone_id                            = var.zone_id
  record_creation_name               = var.record_creation_name
  application_load_balancer_dns_name = module.loadbalancer.application_load_balancer_dns_name
  application_load_balancer_zone_id  = module.loadbalancer.application_load_balancer_zone_id
  aws_lb_target_group_arn            = module.loadbalancer.aws_lb_target_group_arn
  sec_group_application              = module.sec_group_setup.sec_group_application
}

module "loadbalancer" {
  source = "./modules/loadBalancerSetUp"

  vpc_id     = module.vpc_setup.vpc_id
  subnet_ids = module.vpc_setup.subnet_ids

}