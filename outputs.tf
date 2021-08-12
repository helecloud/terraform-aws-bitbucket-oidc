output "roles" {
  description = "IAM roles created mapping."
  value       = aws_iam_role.this
}

output "provider" {
  description = "The OpenID Connect IAM provider"
  value       = aws_iam_openid_connect_provider.bitbucket
}
