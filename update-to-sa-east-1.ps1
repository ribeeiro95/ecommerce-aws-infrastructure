# ========================================
# Script: Atualizar Região e Instance Type
# sa-east-1 (São Paulo) + t3.micro
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Atualizando Projeto para sa-east-1 e t3.micro" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Verificar se está na pasta correta
if (-not (Test-Path "terraform")) {
    Write-Host "ERRO: Execute este script na pasta raiz do projeto!" -ForegroundColor Red
    Write-Host "Exemplo: C:\Users\Gusta\Desktop\ecommerce-aws-infrastructure`n" -ForegroundColor Yellow
    exit 1
}

# ========================================
# 1. BACKUP DOS ARQUIVOS ORIGINAIS
# ========================================

Write-Host "1. Fazendo backup dos arquivos originais..." -ForegroundColor Yellow

$backupFolder = "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null

Copy-Item "terraform\variables.tf" "$backupFolder\variables.tf.bak" -Force
Copy-Item "terraform\terraform.tfvars.example" "$backupFolder\terraform.tfvars.example.bak" -Force

if (Test-Path "terraform\terraform.tfvars") {
    Copy-Item "terraform\terraform.tfvars" "$backupFolder\terraform.tfvars.bak" -Force
    Write-Host "  OK: Backup criado em $backupFolder" -ForegroundColor Green
} else {
    Write-Host "  OK: Backup criado (terraform.tfvars não existe ainda)" -ForegroundColor Green
}

# ========================================
# 2. ATUALIZAR terraform/variables.tf
# ========================================

Write-Host "`n2. Atualizando terraform/variables.tf..." -ForegroundColor Yellow

$variablesContent = @'
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
  default     = "t3.micro"  # Free Tier - Melhor performance que t2.micro
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
'@

Set-Content -Path "terraform\variables.tf" -Value $variablesContent -Encoding UTF8
Write-Host "  OK: variables.tf atualizado" -ForegroundColor Green

# ========================================
# 3. ATUALIZAR terraform.tfvars.example
# ========================================

Write-Host "3. Atualizando terraform.tfvars.example..." -ForegroundColor Yellow

$tfvarsExampleContent = @'
# ========================================
# Terraform Variables - Example
# Copie para terraform.tfvars e ajuste
# ========================================

aws_region   = "sa-east-1"  # Sao Paulo
project_name = "techstore"
environment  = "dev"

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "sa-east-1a",
  "sa-east-1b"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

# Compute Configuration
instance_type        = "t3.micro"  # Free Tier - Melhor que t2.micro
asg_min_size         = 1
asg_max_size         = 3
asg_desired_capacity = 1
'@

Set-Content -Path "terraform\terraform.tfvars.example" -Value $tfvarsExampleContent -Encoding UTF8
Write-Host "  OK: terraform.tfvars.example atualizado" -ForegroundColor Green

# ========================================
# 4. ATUALIZAR/CRIAR terraform.tfvars
# ========================================

Write-Host "4. Atualizando terraform.tfvars..." -ForegroundColor Yellow

if (Test-Path "terraform\terraform.tfvars") {
    Set-Content -Path "terraform\terraform.tfvars" -Value $tfvarsExampleContent -Encoding UTF8
    Write-Host "  OK: terraform.tfvars atualizado" -ForegroundColor Green
} else {
    Set-Content -Path "terraform\terraform.tfvars" -Value $tfvarsExampleContent -Encoding UTF8
    Write-Host "  OK: terraform.tfvars criado" -ForegroundColor Green
}

# ========================================
# 5. ATUALIZAR AWS CLI REGION
# ========================================

Write-Host "`n5. Atualizando AWS CLI para sa-east-1..." -ForegroundColor Yellow

try {
    aws configure set region sa-east-1
    $currentRegion = aws configure get region
    Write-Host "  OK: AWS CLI configurado para $currentRegion" -ForegroundColor Green
} catch {
    Write-Host "  AVISO: Nao foi possivel atualizar AWS CLI automaticamente" -ForegroundColor Yellow
    Write-Host "  Execute manualmente: aws configure set region sa-east-1" -ForegroundColor Yellow
}

# ========================================
# 6. ATUALIZAR README.md
# ========================================

Write-Host "`n6. Atualizando README.md..." -ForegroundColor Yellow

$readmeUpdates = @"

## 🌎 Região e Configuração

**Região AWS:** sa-east-1 (São Paulo, Brasil)
**Instance Type:** t3.micro (Free Tier)

### Por que São Paulo?
- ✅ Menor latência para usuários brasileiros
- ✅ Conformidade com LGPD
- ✅ Dados hospedados no Brasil

### Por que t3.micro?
- ✅ Melhor performance que t2.micro
- ✅ 2 vCPUs vs 1 vCPU
- ✅ Mesmo custo no Free Tier (750h/mês)

"@

# Verificar se README já tem seção de região
$readmeContent = Get-Content "README.md" -Raw

if ($readmeContent -notmatch "## 🌎 Região") {
    # Adicionar antes da seção "Como Usar"
    $readmeContent = $readmeContent -replace "(## Como Usar)", "$readmeUpdates`n`$1"
    Set-Content -Path "README.md" -Value $readmeContent -Encoding UTF8 -NoNewline
    Write-Host "  OK: README.md atualizado com informações de região" -ForegroundColor Green
} else {
    Write-Host "  OK: README.md já contém informações de região" -ForegroundColor Green
}

# ========================================
# 7. LIMPAR ESTADO TERRAFORM (se existir)
# ========================================

Write-Host "`n7. Verificando recursos Terraform existentes..." -ForegroundColor Yellow

if (Test-Path "terraform\.terraform") {
    Write-Host "  Encontrado estado Terraform existente" -ForegroundColor Yellow
    
    $destroy = Read-Host "  Deseja DESTRUIR recursos da região antiga? (s/N)"
    
    if ($destroy -eq "s" -or $destroy -eq "S") {
        Write-Host "`n  Destruindo recursos antigos..." -ForegroundColor Red
        Set-Location terraform
        terraform destroy -auto-approve
        Set-Location ..
        Write-Host "  OK: Recursos destruídos" -ForegroundColor Green
    }
    
    Write-Host "`n  Limpando arquivos de estado..." -ForegroundColor Yellow
    Remove-Item "terraform\.terraform" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "terraform\.terraform.lock.hcl" -Force -ErrorAction SilentlyContinue
    Remove-Item "terraform\terraform.tfstate*" -Force -ErrorAction SilentlyContinue
    Write-Host "  OK: Estado Terraform limpo" -ForegroundColor Green
} else {
    Write-Host "  OK: Nenhum estado Terraform anterior encontrado" -ForegroundColor Green
}

# ========================================
# RESUMO FINAL
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "ATUALIZACAO CONCLUIDA COM SUCESSO!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Mudancas realizadas:" -ForegroundColor Yellow
Write-Host "  ✅ Regiao: us-east-1 → sa-east-1 (Sao Paulo)"
Write-Host "  ✅ Instance Type: t2.micro → t3.micro"
Write-Host "  ✅ Availability Zones: sa-east-1a, sa-east-1b"
Write-Host "  ✅ AWS CLI configurado para sa-east-1"
Write-Host "  ✅ README.md atualizado"
Write-Host "  ✅ Backup criado em: $backupFolder`n"

Write-Host "Proximos passos:" -ForegroundColor Magenta
Write-Host "  1. cd terraform"
Write-Host "  2. terraform init -reconfigure"
Write-Host "  3. terraform plan"
Write-Host "  4. terraform apply"
Write-Host "  5. git add ."
Write-Host "  6. git commit -m 'chore: Muda para sa-east-1 e t3.micro'"
Write-Host "  7. git push`n"

Write-Host "IMPORTANTE:" -ForegroundColor Red
Write-Host "  - Configure Billing Alert na AWS Console!"
Write-Host "  - Instancias t3.micro sao Free Tier (750h/mes)"
Write-Host "  - sa-east-1 pode ter custos um pouco maiores que us-east-1`n"

Write-Host "Comparacao de custos (Free Tier):" -ForegroundColor Cyan
Write-Host "  sa-east-1 vs us-east-1: ~5-10% mais caro"
Write-Host "  MAS no Free Tier: USD 0.00 em ambos!`n"

Write-Host "Pronto para comecar! 🚀`n" -ForegroundColor Green

# Perguntar se quer executar terraform init
$init = Read-Host "Deseja executar 'terraform init -reconfigure' agora? (s/N)"

if ($init -eq "s" -or $init -eq "S") {
    Write-Host "`nInicializando Terraform..." -ForegroundColor Yellow
    Set-Location terraform
    terraform init -reconfigure
    Set-Location ..
    
    Write-Host "`nDeseja ver o plano? (terraform plan) (s/N)" -ForegroundColor Yellow
    $plan = Read-Host
    
    if ($plan -eq "s" -or $plan -eq "S") {
        Set-Location terraform
        terraform plan
        Set-Location ..
    }
}

Write-Host "`nScript concluido!`n" -ForegroundColor Green