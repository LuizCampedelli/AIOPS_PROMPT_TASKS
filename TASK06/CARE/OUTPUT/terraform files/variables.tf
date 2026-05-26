variable "owner" {
  description = "Equipe ou pessoa responsável pela criação e manutenção do bucket"
  type        = string
}

variable "cost_center" {
  description = "Centro de custo associado aos recursos provisionados para faturamento corporativo"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente de implantação (dev, staging, production)"
  type        = string
}

variable "bucket_name_suffix" {
  description = "Sufixo exclusivo para compor o nome do bucket S3. O prefixo 'hvt-' será adicionado automaticamente."
  type        = string
}

variable "log_target_bucket" {
  description = "ID ou Nome do bucket de S3 de destino para armazenar os logs de acesso do novo bucket"
  type        = string
}

variable "log_target_prefix" {
  description = "Prefixo de caminho (path prefix) para organização dos logs no bucket de destino"
  type        = string
  default     = "s3-access-logs/"
}
