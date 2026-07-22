#!/bin/bash

set -euo pipefail
exec > >(tee -a /var/log/devops-user-data.log) 2>&1

echo "Starting user_data for DevOps API"

echo "Checking available Node.js packages"
dnf module list nodejs || true
dnf list available 'nodejs*' 'npm*' || true
dnf info nodejs20 npm || true

echo "Installing required packages"
dnf -y install git nodejs20 npm

echo "Verifying installed versions"
git --version
node --version
npm --version

# Preparar directorio de la aplicación
cd /home/ec2-user
rm -rf ProyectoFinalDevOps
sudo -u ec2-user git clone "${repo_url}" ProyectoFinalDevOps
cd /home/ec2-user/ProyectoFinalDevOps/app
sudo chown -R ec2-user:ec2-user /home/ec2-user/ProyectoFinalDevOps

# Instalar dependencias de la aplicación
sudo -u ec2-user npm install --omit=dev

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
systemctl enable --now devops-api.service

systemctl status devops-api.service --no-pager
curl --fail http://localhost:3000 || true
echo "user_data completed successfully"
