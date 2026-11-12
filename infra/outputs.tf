output "artifacts_bucket_name" {
  description = "Name of the provisioned artifacts bucket."
  value       = aws_s3_bucket.artifacts.id
}
