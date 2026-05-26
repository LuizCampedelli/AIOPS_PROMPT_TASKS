locals {
  common_tags = {
    Owner       = var.owner
    CostCenter  = var.cost_center
    Environment = var.environment
  }

  # Mantém o padrão de prefixo corporativo "hvt-" conforme exigido
  bucket_name = "hvt-${var.bucket_name_suffix}-${var.environment}"
}

# 1. Recurso Principal: Bucket S3
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = merge(local.common_tags, {
    Name = local.bucket_name
  })
}

# 2. Segurança: Habilitação de Criptografia SSE-S3 (Padrão Mínimo Corporativo)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 3. Segurança: Versionamento Ativo para Prevenção de Perdas
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 4. Segurança: Bloqueio Total de Acesso Público
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 5. Auditoria: Configuração de Logging de Acesso
resource "aws_s3_bucket_logging" "this" {
  bucket        = aws_s3_bucket.this.id
  target_bucket = var.log_target_bucket
  target_prefix = var.log_target_prefix
}
