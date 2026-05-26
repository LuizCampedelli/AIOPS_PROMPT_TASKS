module "s3_compliant_bucket" {
  source = "./modules/s3-bucket"

  owner              = "Plataforma de Dados"
  cost_center        = "CC-77049"
  environment        = "production"
  bucket_name_suffix = "analytics-exports"

  # Bucket central de auditoria gerenciado pela equipe de segurança (Strickland)
  log_target_bucket = "hvt-security-audit-logs-production"
  log_target_prefix = "s3-logs/analytics-exports/"
}
