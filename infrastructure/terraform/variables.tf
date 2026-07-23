variable "aws_region" {
  description = "AWS region donde se desplegará la infraestructura."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nombre del entorno o proyecto para etiquetar recursos."
  type        = string
  default     = "devops-academico"
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para la aplicación."
  type        = string
  default     = "t4g.micro"
}

variable "db_instance_class" {
  description = "Clase de instancia para la base de datos RDS."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Almacenamiento inicial en GB para RDS."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Nombre de la base de datos PostgreSQL."
  type        = string
  default     = "devdb"
}

variable "db_username" {
  description = "Usuario administrador de la base de datos PostgreSQL."
  type        = string
  default     = "devuser"
}

variable "db_password_length" {
  description = "Longitud de la contraseña generada para la base de datos."
  type        = number
  default     = 16
}

variable "public_key_path" {
  description = "Ruta local al archivo de clave pública SSH para EC2."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "api_port" {
  description = "Puerto en el que la aplicación escuchará en EC2."
  type        = number
  default     = 3000
}

variable "eks_node_instance_type" {
  description = "Tipo de instancia para nodos EKS (valor por defecto usado si no se pasa otro)."
  type        = string
  default     = "t4g.small"
}

variable "eks_node_min_size" {
  description = "Mínimo de nodos en el node group de EKS."
  type        = number
  default     = 1
}

variable "eks_node_desired_size" {
  description = "Tamaño deseado del node group EKS."
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Máximo de nodos en el node group EKS."
  type        = number
  default     = 3
}

variable "monthly_budget_usd" {
  description = "Límite mensual de referencia para AWS Budgets."
  type        = number
  default     = 10
}
