output "public_ip" {
  description = "IP pública asociada a la instancia EC2."
  value       = aws_eip.app_ip.public_ip
}

output "private_key_pem" {
  description = "Clave privada RSA generada para el par de llaves EC2."
  value       = tls_private_key.deploy_key.private_key_pem
  sensitive   = true
}
