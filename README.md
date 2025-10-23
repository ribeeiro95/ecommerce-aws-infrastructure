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
```
Internet
    |
Application Load Balancer (FREE)
    |
    +-> AZ 1a: EC2 t2.micro (FREE)
    +-> AZ 1b: EC2 t2.micro (FREE)
    
RDS db.t3.micro (FREE)
S3 Bucket (FREE - 5GB)
CloudWatch (FREE - basico)
```

## Como Usar

### Pre-requisitos

- AWS CLI configurado
- Terraform instalado (>= 1.0)
- Conta AWS Free Tier

### Deploy
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
terraform destroy  # SEMPRE destrua apos testes!
```

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
