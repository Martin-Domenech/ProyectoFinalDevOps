provider "aws" {
  region = var.aws_region
}

provider "random" {}

data "aws_vpcs" "default" {
  filter {
    name   = "is-default"
    values = ["true"]
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.default.ids[0]]
  }
}

module "security" {
  source = "./modules/security"

  vpc_id   = data.aws_vpcs.default.ids[0]
  api_port = var.api_port
  rds_port = 5432
}

module "database" {
  source = "./modules/database"

  vpc_id               = data.aws_vpcs.default.ids[0]
  subnet_ids           = data.aws_subnets.default.ids
  db_name              = var.db_name
  db_username          = var.db_username
  db_password_length   = var.db_password_length
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  security_group_id    = module.security.rds_security_group_id
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-arm64-gp2"]
  }

  owners = ["137112412989"]
}

module "compute" {
  source = "./modules/compute"

  ami_id            = data.aws_ami.amazon_linux.id
  instance_type     = var.instance_type
  api_port          = var.api_port
  db_endpoint       = module.database.db_endpoint
  db_port           = 5432
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = module.database.db_password
  security_group_id = module.security.ec2_security_group_id
}
