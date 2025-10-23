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
```bash
aws ce get-cost-and-usage --time-period Start=2025-10-01,End=2025-10-31 --granularity MONTHLY --metrics "UnblendedCost"
```

## Recomendacoes

1. Configure Budget Alert para 1 USD
2. Use AWS Cost Explorer mensalmente
3. Destrua recursos apos cada sessao
