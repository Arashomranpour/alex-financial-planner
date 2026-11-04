variable "aws_region" {
  description = "AWS region where Alex is deployed"
  type        = string
  default     = "us-east-1"
}

variable "github_repository" {
  description = "GitHub repository allowed to deploy, as owner/name"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID of the frontend (from Part 7)"
  type        = string
}
