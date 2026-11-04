variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

# Clerk validation happens in Lambda, not at API Gateway level
variable "clerk_jwks_url" {
  description = "Clerk JWKS URL for JWT validation in Lambda"
  type        = string
}

variable "clerk_issuer" {
  description = "Clerk issuer URL (kept for Lambda environment)"
  type        = string
  default     = ""  # Not actually used but kept for backwards compatibility
}
# Optional overrides for the database; when empty, values come from Part 5 state
variable "aurora_cluster_arn" {
  description = "Aurora cluster ARN (overrides Part 5 state when set)"
  type        = string
  default     = ""
}

variable "aurora_secret_arn" {
  description = "Secrets Manager ARN with Data API credentials (overrides Part 5 state when set)"
  type        = string
  default     = ""
}

variable "aurora_database" {
  description = "Database name (overrides Part 5 state when set)"
  type        = string
  default     = ""
}
