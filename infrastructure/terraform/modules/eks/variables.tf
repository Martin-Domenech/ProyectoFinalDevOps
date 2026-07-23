variable "vpc_id" {
  description = "ID del VPC donde se creará el cluster EKS."
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnet IDs donde crear los nodos del cluster."
  type        = list(string)
}

variable "cluster_name" {
  description = "Nombre del cluster EKS."
  type        = string
  default     = "devops-eks"
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes para el cluster (opcional)."
  type        = string
  default     = null
}

variable "node_instance_type" {
  description = "Tipo de instancia para los nodos EKS."
  type        = string
  default     = "t4g.small"
}

variable "node_min_size" {
  description = "Tamaño mínimo del node group."
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Tamaño deseado del node group."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Tamaño máximo del node group."
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Tamaño del disco en GB para nodos."
  type        = number
  default     = 20
}

variable "tags" {
  description = "Mapa de tags que se aplicarán a recursos del cluster."
  type        = map(string)
  default     = {}
}
