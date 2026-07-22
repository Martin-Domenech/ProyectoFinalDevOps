output "db_endpoint" {
  description = "Endpoint de conexión de la instancia RDS."
  value       = aws_db_instance.postgres.endpoint
}

output "db_password" {
  description = "Contraseña generada para la base de datos."
  value       = random_password.db.result
  sensitive   = true
}
