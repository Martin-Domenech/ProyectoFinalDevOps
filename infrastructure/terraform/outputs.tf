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
