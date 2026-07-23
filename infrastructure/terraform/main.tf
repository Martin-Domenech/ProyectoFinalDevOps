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

data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*al2023*arm64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

module "compute" {
  source = "./modules/compute"

  ami_id            = data.aws_ami.amazon_linux_2023.id
  instance_type     = var.instance_type
  api_port          = var.api_port
  db_endpoint       = module.database.db_endpoint
  db_port           = 5432
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = module.database.db_password
  security_group_id = module.security.ec2_security_group_id
  repo_url          = "https://github.com/Martin-Domenech/ProyectoFinalDevOps.git"
}

module "eks" {
  source = "./modules/eks"

  vpc_id             = data.aws_vpcs.default.ids[0]
  subnet_ids         = data.aws_subnets.default.ids
  cluster_name       = "${var.environment}-eks"
  node_instance_type = var.eks_node_instance_type
  node_min_size      = var.eks_node_min_size
  node_desired_size  = var.eks_node_desired_size
  node_max_size      = var.eks_node_max_size
  node_disk_size     = 20
  tags               = { Environment = var.environment }
}

module "finops" {
  source = "./modules/finops"

  environment        = var.environment
  monthly_budget_usd = var.monthly_budget_usd
}

# Permitir que solo el Security Group de nodos EKS acceda a RDS (puerto 5432)
resource "aws_security_group_rule" "rds_allow_from_eks_nodes" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.security.rds_security_group_id
  source_security_group_id = module.eks.node_security_group_id
  description              = "Allow Postgres only from EKS node security group"
}
