output "github_deploy_role_arn" {
  description = "Set this as the AWS_ROLE_ARN repository variable in GitHub"
  value       = aws_iam_role.github_deploy.arn
}

output "setup_instructions" {
  description = "Next steps after applying"
  value       = <<-EOT

    ✅ GitHub Actions deploy role created!

    Role ARN: ${aws_iam_role.github_deploy.arn}
    Trusted:  repo:${var.github_repository}:ref:refs/heads/main

    Next steps:
    1. Store the role ARN as a repository variable (exact command):
       gh variable set AWS_ROLE_ARN -R ${var.github_repository} -b ${aws_iam_role.github_deploy.arn}

    2. Make sure these variables exist too:
       AWS_REGION, FRONTEND_BUCKET, CLOUDFRONT_DISTRIBUTION_ID,
       LAMBDA_PACKAGES_BUCKET, API_URL, CLERK_PUBLISHABLE_KEY

    3. Test: GitHub → Actions → "Deploy frontend" → Run workflow
  EOT
}
