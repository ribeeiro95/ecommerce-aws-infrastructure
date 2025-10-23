﻿# ========================================
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
