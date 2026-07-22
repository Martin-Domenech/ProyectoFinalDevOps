variable "vpc_id" {
  description = "ID del VPC que contiene las subredes."
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnets donde se crea la instancia RDS."
  type        = list(string)
}

variable "db_name" {
  description = "Nombre de la base de datos."
  type        = string
}

variable "db_username" {
  description = "Usuario de la base de datos."
  type        = string
}

variable "db_password_length" {
  description = "Longitud de la contraseña generada para RDS."
  type        = number
}

variable "db_instance_class" {
  description = "Clase de instancia RDS."
  type        = string
}

variable "db_allocated_storage" {
  description = "Almacenamiento inicial para RDS en GB."
  type        = number
}

variable "security_group_id" {
  description = "Security group que permite acceso a RDS."
  type        = string
}
