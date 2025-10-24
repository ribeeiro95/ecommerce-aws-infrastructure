# ========================================
# Variables - Main Configuration
# ========================================

variable "aws_region" {
  description = "Regiao AWS para criar recursos"
  type        = string
  default     = "sa-east-1"  # Sao Paulo
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "techstore"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Lista de Availability Zones"
  type        = list(string)
  default     = ["sa-east-1a", "sa-east-1b"]  # Sao Paulo AZs
}

variable "public_subnet_cidrs" {
  description = "CIDRs para subnets publicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# ========================================
# Compute Variables
# ========================================

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"  # Free Tier
}

variable "asg_min_size" {
  description = "Numero minimo de instancias"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Numero maximo de instancias"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Numero desejado de instancias"
  type        = number
  default     = 1
}