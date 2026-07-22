variable "ami_id" {
  description = "ID de la AMI para la instancia EC2."
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2."
  type        = string
}

variable "api_port" {
  description = "Puerto en el que la aplicación escucha."
  type        = number
}

variable "db_endpoint" {
  description = "Endpoint de RDS para la aplicación."
  type        = string
}

variable "db_port" {
  description = "Puerto de PostgreSQL."
  type        = number
}

variable "db_name" {
  description = "Nombre de la base de datos."
  type        = string
}

variable "db_username" {
  description = "Usuario de la base de datos."
  type        = string
}

variable "db_password" {
  description = "Contraseña de la base de datos."
  type        = string
  sensitive   = true
}

variable "security_group_id" {
  description = "Security group asociado a EC2."
  type        = string
}

variable "repo_url" {
  description = "URL del repositorio Git para clonar la aplicación."
  type        = string
  default     = ""
}
