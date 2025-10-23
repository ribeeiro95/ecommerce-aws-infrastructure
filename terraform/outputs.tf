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
