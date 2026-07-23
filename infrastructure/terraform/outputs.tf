output "api_url" {
  description = "URL pública para acceder a la API."
  value       = "http://${module.compute.public_ip}:${var.api_port}"
}

output "ec2_public_ip" {
  description = "IP pública de la instancia EC2."
  value       = module.compute.public_ip
}

output "ssh_command" {
  description = "Comando SSH para conectarse a la instancia EC2."
  value       = "ssh -i <private-key> ec2-user@${module.compute.public_ip}"
}

output "private_key_pem" {
  description = "Private key for SSH access to the EC2 instance"
  value       = module.compute.private_key_pem
  sensitive   = true
}

output "rds_endpoint" {
  description = "Endpoint de la base de datos RDS."
  value       = module.database.db_endpoint
}

output "db_password" {
  description = "Contraseña generada para inyectar en Kubernetes."
  value       = module.database.db_password
  sensitive   = true
}

output "eks_cluster_name" {
  description = "Nombre del cluster EKS creado."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint del API server de EKS."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca" {
  description = "Certificado CA del cluster EKS (base64)."
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "budget_name" {
  description = "Presupuesto mensual para monitoreo FinOps."
  value       = module.finops.budget_name
}
