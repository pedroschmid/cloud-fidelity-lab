resource "aws_s3_bucket" "artifacts" {
  bucket = "cloud-fidelity-lab-${var.environment}-artifacts"

  tags = {
    Project     = "cloud-fidelity-lab"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
