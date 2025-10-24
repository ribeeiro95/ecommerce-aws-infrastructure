# ========================================
# Data Source - Latest Amazon Linux 2023 AMI
# ========================================
# Busca automaticamente a AMI mais recente

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ========================================
# Launch Template
# ========================================
# Modelo para criar instâncias EC2
# Substitui Launch Configuration (legado)

resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-lt-"
  description   = "Launch template for ${var.project_name} EC2 instances"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  # User Data - script de inicialização
  user_data = base64encode(file("${path.module}/user-data.sh"))

  # Security Group
  vpc_security_group_ids = [var.security_group_id]

  # Monitoramento detalhado (FREE TIER: use false)
  monitoring {
    enabled = var.enable_monitoring
  }

  # Metadata options (segurança)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 (mais seguro)
    http_put_response_hop_limit = 1
  }

  # Tags que serão aplicadas às instâncias
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-ec2"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name        = "${var.project_name}-ec2-volume"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  # Lifecycle
  lifecycle {
    create_before_destroy = true
  }
}

# ========================================
# Auto Scaling Group
# ========================================
# Gerencia automaticamente as instâncias EC2
# Mantém número desejado de instâncias rodando

resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.subnet_ids
  
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  # Health check
  health_check_type         = "EC2"  # Mudará para ELB quando adicionar ALB
  health_check_grace_period = 300    # 5 minutos para instância ficar saudável

  # Launch template
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"  # Sempre usa última versão
  }

  # Tempo de espera para operações
  default_cooldown          = 300  # 5 minutos entre scale events
  wait_for_capacity_timeout = "10m"

  # Tags
  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform-ASG"
    propagate_at_launch = true
  }

  # Lifecycle
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]  # Permite scaling manual
  }
}

# ========================================
# Auto Scaling Policy - Scale Up
# ========================================
# Adiciona instâncias quando CPU > 70%

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1        # Adiciona 1 instância
  cooldown               = 300      # Espera 5 min antes de escalar novamente
  policy_type            = "SimpleScaling"
}

# CloudWatch Alarm - High CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2           # 2 períodos consecutivos
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120         # 2 minutos
  statistic           = "Average"
  threshold           = 70          # 70% CPU

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  alarm_description = "Triggers scale up when CPU > 70%"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]

  tags = {
    Name        = "${var.project_name}-high-cpu-alarm"
    Environment = var.environment
  }
}

# ========================================
# Auto Scaling Policy - Scale Down
# ========================================
# Remove instâncias quando CPU < 30%

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1       # Remove 1 instância
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

# CloudWatch Alarm - Low CPU
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.project_name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30          # 30% CPU

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  alarm_description = "Triggers scale down when CPU < 30%"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]

  tags = {
    Name        = "${var.project_name}-low-cpu-alarm"
    Environment = var.environment
  }
}