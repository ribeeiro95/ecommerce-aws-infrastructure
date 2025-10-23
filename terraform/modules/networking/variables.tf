# ========================================
# Networking Module - Variables
# ========================================

variable "project_name" {
  description = "Nome do projeto para tags"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
}

variable "availability_zones" {
  description = "Lista de AZs para usar"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs para subnets publicas"
  type        = list(string)
}
