#!/bin/bash

set -e

# Install system dependencies
yum update -y
yum install -y git

# Instalar Node.js
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs

# Clonar el repositorio y entrar en la carpeta de la app
cd /home/ec2-user
rm -rf ProyectoFinalDevOps
sudo -u ec2-user git clone "${repo_url}" ProyectoFinalDevOps
cd /home/ec2-user/ProyectoFinalDevOps/app
sudo chown -R ec2-user:ec2-user /home/ec2-user/ProyectoFinalDevOps

# Instalar dependencias de la aplicación
sudo -u ec2-user npm install --production

# Crear archivo .env para la aplicación
cat > /home/ec2-user/ProyectoFinalDevOps/app/.env <<EOF
DB_HOST=${db_endpoint}
DB_PORT=${db_port}
DB_NAME=${db_name}
DB_USER=${db_username}
DB_PASSWORD=${db_password}
PORT=${api_port}
EOF
sudo chown ec2-user:ec2-user /home/ec2-user/ProyectoFinalDevOps/app/.env

# Crear unidad systemd para ejecutar la aplicación
cat > /etc/systemd/system/devops-api.service <<'SERVICE'
[Unit]
Description=DevOps API service
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/ProyectoFinalDevOps/app
EnvironmentFile=/home/ec2-user/ProyectoFinalDevOps/app/.env
ExecStart=/usr/bin/npm start
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable devops-api.service
systemctl start devops-api.service
