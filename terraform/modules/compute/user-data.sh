#!/bin/bash
# ========================================
# User Data Script - EC2 Initialization
# ========================================
# Este script roda automaticamente quando a instância é criada

# Atualizar sistema
yum update -y

# Instalar NGINX
amazon-linux-extras install nginx1 -y

# Criar página HTML personalizada
cat > /usr/share/nginx/html/index.html <<'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechStore - E-Commerce Infrastructure</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 600px;
            width: 100%;
        }
        
        h1 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        
        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 1.1em;
        }
        
        .info-card {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin-bottom: 15px;
            border-radius: 5px;
        }
        
        .info-card h3 {
            color: #333;
            margin-bottom: 8px;
            font-size: 1em;
        }
        
        .info-card p {
            color: #666;
            margin: 5px 0;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }
        
        .status {
            display: inline-block;
            background: #10b981;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: bold;
            margin-top: 20px;
        }
        
        .footer {
            margin-top: 30px;
            text-align: center;
            color: #999;
            font-size: 0.9em;
        }
        
        .badge {
            display: inline-block;
            background: #667eea;
            color: white;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.8em;
            margin-left: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏪 TechStore</h1>
        <p class="subtitle">E-Commerce Infrastructure</p>
        
        <div class="info-card">
            <h3>📍 Instance Information</h3>
            <p><strong>Instance ID:</strong> <span id="instance-id">Loading...</span></p>
            <p><strong>Availability Zone:</strong> <span id="az">Loading...</span></p>
            <p><strong>Region:</strong> <span id="region">Loading...</span></p>
        </div>
        
        <div class="info-card">
            <h3>🖥️ Server Status</h3>
            <p><strong>Web Server:</strong> NGINX <span class="badge">Active</span></p>
            <p><strong>Platform:</strong> Amazon Linux 2023</p>
            <p><strong>Managed By:</strong> Terraform + Auto Scaling</p>
        </div>
        
        <div class="info-card">
            <h3>🏗️ Architecture</h3>
            <p>✅ VPC with Multi-AZ</p>
            <p>✅ Auto Scaling Group</p>
            <p>✅ Application Load Balancer</p>
            <p>✅ RDS MySQL Database</p>
            <p>✅ S3 Storage</p>
        </div>
        
        <div style="text-align: center;">
            <span class="status">🚀 System Online</span>
        </div>
        
        <div class="footer">
            <p>Desenvolvido por <strong>Gustavo Ribeiro do Vale</strong></p>
            <p>AWS Free Tier | Terraform IaC</p>
        </div>
    </div>
    
    <script>
        // Buscar informações da instância via metadata service
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instance-id').textContent = data)
            .catch(() => document.getElementById('instance-id').textContent = 'N/A');
        
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => {
                document.getElementById('az').textContent = data;
                document.getElementById('region').textContent = data.slice(0, -1);
            })
            .catch(() => {
                document.getElementById('az').textContent = 'N/A';
                document.getElementById('region').textContent = 'N/A';
            });
    </script>
</body>
</html>
EOF

# Iniciar NGINX
systemctl start nginx
systemctl enable nginx

# Configurar firewall (permitir HTTP)
systemctl start firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# Log de conclusão
echo "User Data script completed successfully" > /var/log/user-data.log
date >> /var/log/user-data.log