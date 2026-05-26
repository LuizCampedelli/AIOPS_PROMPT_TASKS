output "bucket_id" {
  description = "O nome/ID único do bucket S3 criado"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "A Amazon Resource Name (ARN) do bucket S3 criado"
  value       = aws_s3_bucket.this.arn
}
