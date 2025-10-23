# ========================================
# TechStore - Setup Completo do Projeto
# Cria TODA estrutura e arquivos automaticamente
# ========================================

Write-Host "Iniciando setup completo do TechStore..." -ForegroundColor Green

# ========================================
# 1. CRIAR ESTRUTURA DE PASTAS
# ========================================

Write-Host "`nCriando estrutura de pastas..." -ForegroundColor Yellow

$folders = @(
    "terraform\modules\networking",
    "terraform\scripts",
    "diagrams",
    "docs"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    Write-Host "  OK: $folder" -ForegroundColor Green
}

# ========================================
# 2. CRIAR .gitignore
# ========================================

Write-Host "`nCriando .gitignore..." -ForegroundColor Yellow

$gitignoreContent = @"
# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
terraform.tfvars
crash.log
override.tf
override.tf.json

# AWS
*.pem
*.key

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
"@

Set-Content -Path ".gitignore" -Value $gitignoreContent -Encoding UTF8
Write-Host "  OK: .gitignore criado" -ForegroundColor Green

# ========================================
# 3. CRIAR README.md
# ========================================

Write-Host "Criando README.md..." -ForegroundColor Yellow

$readmeContent = @"
# TechStore - E-Commerce Infrastructure (AWS Free Tier)

Infraestrutura completa para e-commerce na AWS, otimizada para Free Tier (sem custos).

## Importante: Custos

Este projeto foi projetado para NAO GERAR CUSTOS no Free Tier da AWS.

**Servicos utilizados (Free Tier):**
- EC2 t2.micro: 750h/mes gratis
- RDS db.t3.micro: 750h/mes gratis  
- ALB: 750h/mes gratis
- S3: 5GB gratis
- VPC, Subnets, IGW: Gratuitos

**O que NAO usamos:**
- NAT Gateway (~32 USD/mes)
- RDS Multi-AZ (dobra o custo)

## Objetivo

Demonstrar capacidade de:
- Projetar arquiteturas AWS
- Usar Terraform para IaC
- Aplicar boas praticas de seguranca
- Documentar profissionalmente

## Arquitetura
``````
Internet
    |
Application Load Balancer (FREE)
    |
    +-> AZ 1a: EC2 t2.micro (FREE)
    +-> AZ 1b: EC2 t2.micro (FREE)
    
RDS db.t3.micro (FREE)
S3 Bucket (FREE - 5GB)
CloudWatch (FREE - basico)
``````

## Como Usar

### Pre-requisitos

- AWS CLI configurado
- Terraform instalado (>= 1.0)
- Conta AWS Free Tier

### Deploy
``````bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
terraform destroy  # SEMPRE destrua apos testes!
``````

## Status do Projeto

- [x] Fase 1: Networking (VPC, Subnets, Security Groups)
- [ ] Fase 2: Compute (EC2, Auto Scaling)
- [ ] Fase 3: Load Balancing (ALB)
- [ ] Fase 4: Database (RDS)
- [ ] Fase 5: Storage (S3)

## Avisos Importantes

1. SEMPRE destrua os recursos apos estudar
2. Configure Billing Alerts na AWS
3. Nao deixe recursos rodando sem necessidade

---

**Desenvolvido por:** Gustavo Ribeiro do Vale  
**GitHub:** github.com/ribeeiro95  
**Contato:** gustavordovale@gmail.com
"@

Set-Content -Path "README.md" -Value $readmeContent -Encoding UTF8
Write-Host "  OK: README.md criado" -ForegroundColor Green

# ========================================
# 4. CRIAR CUSTOS.md
# ========================================

Write-Host "Criando CUSTOS.md..." -ForegroundColor Yellow

$custosContent = @"
# Analise de Custos - TechStore Infrastructure

## Versao Free Tier (ATUAL)

**Custo Total Mensal: 0.00 USD**

Servicos Free Tier utilizados:
- EC2 t2.micro: 2 instancias - 750h/mes gratis - Custo: 0.00 USD
- RDS db.t3.micro: 1 instancia - 750h/mes gratis - Custo: 0.00 USD
- ALB: 1 - 750h/mes gratis - Custo: 0.00 USD
- S3 Standard: menor que 5GB - 5GB gratis - Custo: 0.00 USD
- VPC: 1 - Gratuito - Custo: 0.00 USD

*Desde que nao exceda 750h/mes

## Cuidados:

1. NAO deixe 2 EC2 rodando 24/7 - Excede 750h
2. Sempre destrua apos estudar
3. Monitor billing diariamente

## Como Monitorar

**AWS Console:** https://console.aws.amazon.com/billing/home

**AWS CLI:**
``````bash
aws ce get-cost-and-usage --time-period Start=2025-10-01,End=2025-10-31 --granularity MONTHLY --metrics "UnblendedCost"
``````

## Recomendacoes

1. Configure Budget Alert para 1 USD
2. Use AWS Cost Explorer mensalmente
3. Destrua recursos apos cada sessao
"@

Set-Content -Path "CUSTOS.md" -Value $custosContent -Encoding UTF8
Write-Host "  OK: CUSTOS.md criado" -ForegroundColor Green

# ========================================
# 5. TERRAFORM - MAIN.TF
# ========================================

Write-Host "`nCriando arquivos Terraform..." -ForegroundColor Yellow

$mainTfContent = @"
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
"@

Set-Content -Path "terraform\main.tf" -Value $mainTfContent -Encoding UTF8
Write-Host "  OK: terraform/main.tf" -ForegroundColor Green

# ========================================
# 6. TERRAFORM - VARIABLES.TF
# ========================================

$variablesTfContent = @"
# ========================================
# Variables - Main Configuration
# ========================================

variable "aws_region" {
  description = "Regiao AWS para criar recursos"
  type        = string
  default     = "us-east-1"
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
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs para subnets publicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
"@

Set-Content -Path "terraform\variables.tf" -Value $variablesTfContent -Encoding UTF8
Write-Host "  OK: terraform/variables.tf" -ForegroundColor Green

# ========================================
# 7. TERRAFORM - OUTPUTS.TF
# ========================================

$outputsTfContent = @"
# ========================================
# Outputs - Informacoes da Infraestrutura
# ========================================

output "vpc_info" {
  description = "Informacoes da VPC"
  value = {
    vpc_id     = module.networking.vpc_id
    vpc_cidr   = module.networking.vpc_cidr
    subnet_ids = module.networking.public_subnet_ids
  }
}

output "security_groups" {
  description = "IDs dos Security Groups"
  value = {
    alb_sg = module.networking.alb_security_group_id
    ec2_sg = module.networking.ec2_security_group_id
    rds_sg = module.networking.rds_security_group_id
  }
}

output "next_steps" {
  description = "Proximos passos"
  value = <<-EOT
    
    VPC criada com sucesso!
    
    Recursos criados:
    - VPC com subnets publicas em 2 AZs
    - Internet Gateway
    - Security Groups (ALB, EC2, RDS)
    
    Proximos modulos:
    - Compute (EC2 + Auto Scaling)
    - Load Balancer (ALB)
    - Database (RDS)
    - Storage (S3)
    
    Para destruir: terraform destroy
  EOT
}
"@

Set-Content -Path "terraform\outputs.tf" -Value $outputsTfContent -Encoding UTF8
Write-Host "  OK: terraform/outputs.tf" -ForegroundColor Green

# ========================================
# 8. TERRAFORM.TFVARS.EXAMPLE
# ========================================

$tfvarsContent = @"
# ========================================
# Terraform Variables - Example
# Copie para terraform.tfvars e ajuste
# ========================================

aws_region   = "us-east-1"
project_name = "techstore"
environment  = "dev"

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]
"@

Set-Content -Path "terraform\terraform.tfvars.example" -Value $tfvarsContent -Encoding UTF8
Write-Host "  OK: terraform/terraform.tfvars.example" -ForegroundColor Green

# ========================================
# 9. MODULO NETWORKING - VARIABLES
# ========================================

Write-Host "`nCriando modulo networking..." -ForegroundColor Yellow

$netVarsContent = @"
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
"@

Set-Content -Path "terraform\modules\networking\variables.tf" -Value $netVarsContent -Encoding UTF8
Write-Host "  OK: networking/variables.tf" -ForegroundColor Green

# ========================================
# 10. MODULO NETWORKING - MAIN
# ========================================

$netMainContent = @'
# ========================================
# VPC - Virtual Private Cloud
# ========================================
# FREE TIER: VPC eh gratuita
# Cria uma rede isolada na AWS

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ========================================
# Internet Gateway
# ========================================
# FREE TIER: Internet Gateway eh gratuito
# Permite acesso a internet

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# ========================================
# Subnets Publicas
# ========================================
# FREE TIER: Subnets sao gratuitas
# Cada subnet em uma AZ diferente (alta disponibilidade)

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Public"
    AZ          = var.availability_zones[count.index]
  }
}

# ========================================
# Route Table - Publica
# ========================================
# Direciona trafego para Internet Gateway

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

# Associar subnets a route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
'@

Set-Content -Path "terraform\modules\networking\main.tf" -Value $netMainContent -Encoding UTF8
Write-Host "  OK: networking/main.tf" -ForegroundColor Green

# ========================================
# 11. MODULO NETWORKING - SECURITY GROUPS
# ========================================

$sgContent = @'
# ========================================
# Security Group - Application Load Balancer
# ========================================
# Permite HTTP/HTTPS da internet

resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-sg-"
  description = "Security group para ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP da internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS da internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ========================================
# Security Group - EC2 Instances
# ========================================
# Aceita trafego APENAS do Load Balancer

resource "aws_security_group" "ec2" {
  name_prefix = "${var.project_name}-ec2-sg-"
  description = "Security group para instancias EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP do ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH para manutencao"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Prod: restringir ao seu IP
  }

  egress {
    description = "Todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ec2-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ========================================
# Security Group - RDS Database
# ========================================
# Aceita MySQL APENAS das instancias EC2

resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-sg-"
  description = "Security group para RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL das EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "Todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}
'@

Set-Content -Path "terraform\modules\networking\security_groups.tf" -Value $sgContent -Encoding UTF8
Write-Host "  OK: networking/security_groups.tf" -ForegroundColor Green

# ========================================
# 12. MODULO NETWORKING - OUTPUTS
# ========================================

$netOutputsContent = @"
# ========================================
# Networking Module - Outputs
# ========================================

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block da VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs das subnets publicas"
  value       = aws_subnet.public[*].id
}

output "alb_security_group_id" {
  description = "ID do Security Group do ALB"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "ID do Security Group das EC2"
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = aws_security_group.rds.id
}
"@

Set-Content -Path "terraform\modules\networking\outputs.tf" -Value $netOutputsContent -Encoding UTF8
Write-Host "  OK: networking/outputs.tf" -ForegroundColor Green

# ========================================
# RESUMO FINAL
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SETUP CONCLUIDO COM SUCESSO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nArquivos criados:" -ForegroundColor Yellow
Write-Host "  - Estrutura de pastas completa"
Write-Host "  - 12 arquivos de configuracao"
Write-Host "  - Modulo Networking completo"
Write-Host "  - Documentacao"

Write-Host "`nProximos passos:" -ForegroundColor Magenta
Write-Host "  1. cd terraform"
Write-Host "  2. cp terraform.tfvars.example terraform.tfvars"
Write-Host "  3. terraform init"
Write-Host "  4. terraform plan"
Write-Host "  5. terraform apply"
Write-Host "  6. terraform destroy (SEMPRE!)"

Write-Host "`nLEMBRE-SE:" -ForegroundColor Red
Write-Host "  - Configure Billing Alert na AWS!"
Write-Host "  - Sempre destrua recursos apos estudar"

Write-Host "`nPronto para começar!`n" -ForegroundColor Green