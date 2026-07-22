variable "vpc_id" {
  description = "ID del VPC donde se crean los security groups."
  type        = string
}

variable "api_port" {
  description = "Puerto público de la API."
  type        = number
}

variable "rds_port" {
  description = "Puerto de PostgreSQL en RDS."
  type        = number
}
