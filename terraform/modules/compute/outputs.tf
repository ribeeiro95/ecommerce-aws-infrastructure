# ========================================
# Compute Module - Outputs
# ========================================

output "launch_template_id" {
  description = "ID do Launch Template"
  value       = aws_launch_template.main.id
}

output "launch_template_latest_version" {
  description = "Última versão do Launch Template"
  value       = aws_launch_template.main.latest_version
}

output "autoscaling_group_id" {
  description = "ID do Auto Scaling Group"
  value       = aws_autoscaling_group.main.id
}

output "autoscaling_group_name" {
  description = "Nome do Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "autoscaling_group_arn" {
  description = "ARN do Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "scale_up_policy_arn" {
  description = "ARN da política de scale up"
  value       = aws_autoscaling_policy.scale_up.arn
}

output "scale_down_policy_arn" {
  description = "ARN da política de scale down"
  value       = aws_autoscaling_policy.scale_down.arn
}