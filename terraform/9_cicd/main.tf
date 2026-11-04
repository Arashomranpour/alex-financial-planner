terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  common_tags = {
    Project = "alex"
    Part    = "9_cicd"
  }
}

# GitHub Actions OIDC identity provider (one per account; import it if it already exists)
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  tags           = local.common_tags
}

# Role assumed by GitHub Actions - only from the main branch of this repository
resource "aws_iam_role" "github_deploy" {
  name        = "alex-github-actions-deploy"
  description = "GitHub Actions deploy role for ${var.github_repository} (main branch only)"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:ref:refs/heads/main"
        }
      }
    }]
  })

  tags = local.common_tags
}

# Least privilege: sync the frontend bucket, invalidate CloudFront, update the Lambda code
resource "aws_iam_role_policy" "github_deploy" {
  name = "alex-deploy"
  role = aws_iam_role.github_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListBuckets"
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = [
          "arn:aws:s3:::alex-frontend-${local.account_id}",
          "arn:aws:s3:::alex-lambda-packages-${local.account_id}"
        ]
      },
      {
        Sid    = "WriteObjects"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = [
          "arn:aws:s3:::alex-frontend-${local.account_id}/*",
          "arn:aws:s3:::alex-lambda-packages-${local.account_id}/*"
        ]
      },
      {
        Sid      = "InvalidateCdn"
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation", "cloudfront:GetInvalidation"]
        Resource = "arn:aws:cloudfront::${local.account_id}:distribution/${var.cloudfront_distribution_id}"
      },
      {
        Sid    = "UpdateLambdaCode"
        Effect = "Allow"
        Action = ["lambda:UpdateFunctionCode", "lambda:GetFunction", "lambda:GetFunctionConfiguration"]
        Resource = [
          for name in ["api", "planner", "tagger", "reporter", "charter", "retirement"] :
          "arn:aws:lambda:${var.aws_region}:${local.account_id}:function:alex-${name}"
        ]
      }
    ]
  })
}
