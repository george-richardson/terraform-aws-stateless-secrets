output "kms_key_arn" {
  description = "The ARN of the KMS key to be used to encrypt secret value or data keys for secrets to be stored in version control."
  value       = aws_kms_key.terraform_secrets.arn
}

output "kms_alias_arn" {
  description = "The ARN of the KMS alias to be used to encrypt secret value or data keys for secrets to be stored in version control."
  value       = aws_kms_alias.terraform_secrets.arn
}

output "secret_arns" {
  description = "Map of created secret's names to ARNs."
  value       = { for secret in aws_secretsmanager_secret.secret : secret.name => secret.arn }
}
