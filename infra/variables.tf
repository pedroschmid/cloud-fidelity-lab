variable "aws_region" {
  description = "AWS region used for local infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "aws_endpoint" {
  description = "Local AWS Emulator endpoint."
  type        = string
  default     = "https://127.0.0.1:9297"

  validation {
    condition     = var.aws_endpoint == "https://127.0.0.1:9297"
    error_message = "Only the local AWS Emulator endpoint is allowed."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}
