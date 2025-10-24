# ========================================
# Provider Configuration
# ========================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "TechStore"
      Environment = var.environment
      ManagedBy   = "Terraform"
      CostCenter  = "Free-Tier"
      Owner       = "Gustavo Ribeiro"
    }
  }
}

# ========================================
# Networking Module
# ========================================

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment
  
  vpc_cidr = var.vpc_cidr
  
  availability_zones = var.availability_zones
  
  public_subnet_cidrs = var.public_subnet_cidrs
}

# ========================================
# Compute Module
# ========================================

module "compute" {
  source = "./modules/compute"

  project_name = var.project_name
  environment  = var.environment
  
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.public_subnet_ids
  security_group_id = module.networking.ec2_security_group_id
  
  instance_type    = var.instance_type
  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity
}