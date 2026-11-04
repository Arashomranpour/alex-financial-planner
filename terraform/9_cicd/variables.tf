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

variable "create_oidc_provider" {
  description = "Create the GitHub OIDC provider; set false if the account already has one"
  type        = bool
  default     = true
}

# Numeric ids for GitHub's immutable-id OIDC subject format
# (gh api repos/<owner>/<repo> --jq '"\(.owner.id) \(.id)"')
variable "github_owner_id" {
  description = "Numeric GitHub id of the repository owner"
  type        = string
  default     = ""
}

variable "github_repository_id" {
  description = "Numeric GitHub id of the repository"
  type        = string
  default     = ""
}
