#!/bin/bash

set -e

# Actualizar e instalar dependencias básicas
yum update -y
amazon-linux-extras enable docker
yum install -y docker git
service docker start
usermod -a -G docker ec2-user

# Clonar la aplicación si se provee repo_url
%{ if repo_url != "" }
cd /home/ec2-user
sudo -u ec2-user git clone "${repo_url}" app
cd /home/ec2-user/app
%{ else }
cd /home/ec2-user/app
%{ endif }

# Instalar Node y dependencias
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs
npm install --production

# Crear archivo .env para la aplicación
cat > .env <<EOF
DB_HOST=${db_endpoint}
DB_PORT=${db_port}
DB_NAME=${db_name}
DB_USER=${db_username}
DB_PASSWORD=${db_password}
PORT=${api_port}
EOF

# Iniciar la aplicación
nohup npm start > app.log 2>&1 &
