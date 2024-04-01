output "kms_key_arn" {
  description = "The ARN of the KMS key to be used to encrypt secret value or data keys for secrets to be stored in version control."
  value       = aws_kms_key.terraform_secrets.arn
}

output "kms_alias_arn" {
  description = "The ARN of the KMS alias to be used to encrypt secret value or data keys for secrets to be stored in version control."
  value       = aws_kms_alias.terraform_secrets.arn
}
