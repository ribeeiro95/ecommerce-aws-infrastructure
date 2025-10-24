# ========================================
# Compute Module - Variables
# ========================================

variable "project_name" {
  description = "Nome do projeto para tags"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das subnets para instâncias EC2"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID do Security Group para EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instância EC2"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "ID da AMI (deixe vazio para usar a mais recente do Amazon Linux 2023)"
  type        = string
  default     = ""
}

variable "min_size" {
  description = "Número mínimo de instâncias no Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Número máximo de instâncias no Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Número desejado de instâncias"
  type        = number
  default     = 1
}

variable "enable_monitoring" {
  description = "Habilitar monitoramento detalhado (cuidado: pode ter custo extra)"
  type        = bool
  default     = false
}