data "aws_caller_identity" "current" {}

resource "aws_kms_key" "terraform_secrets" {
  description             = "Used to encrypt secrets for storage in version control to be deployed later by Terraform."
  policy                  = var.key_policy != null ? var.key_policy : data.aws_iam_policy_document.terraform_secrets_key_policy.json
  deletion_window_in_days = var.key_deletion_window_in_days
  enable_key_rotation     = true
}

resource "aws_kms_alias" "terraform_secrets" {
  name          = "alias/terraform-secrets"
  target_key_id = aws_kms_key.terraform_secrets.key_id
}

data "aws_iam_policy_document" "terraform_secrets_key_policy" {
  # checkov:skip=CKV_AWS_111:This is the default KMS policy statement
  # checkov:skip=CKV_AWS_109:This is the default KMS policy statement
  # checkov:skip=CKV_AWS_356:This is a resource based policy that ignores resource wildcards
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  dynamic "statement" {
    for_each = length(var.encrypt_principals) > 0 ? ["true"] : []
    content {
      sid       = "Encrypt"
      actions   = ["kms:Encrypt", "kms:GenerateDataKey*"]
      resources = "*"
      principals {
        type        = "AWS"
        identifiers = var.encrypt_principals
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.decrypt_principals) > 0 ? ["true"] : []
    content {
      sid       = "Decrypt"
      actions   = ["kms:Decrypt"]
      resources = "*"
      principals {
        type        = "AWS"
        identifiers = var.decrypt_principals
      }
    }
  }
}

resource "aws_secretsmanager_secret" "secret" {
  # checkov:skip=CKV2_AWS_57:This secret cannot be automatically rotated as that defeats the purpose of the module.
  for_each                = { for secret in var.secrets : secret.name => secret }
  name                    = each.value.name
  description             = each.value.description
  policy                  = each.value.policy
  recovery_window_in_days = each.value.recovery_window_in_days
  kms_key_id              = each.value.secret_kms_key_id
}

module "secrets" {
  source   = "./modules/stateless-secret"
  for_each = { for secret in var.secrets : secret.name => secret }

  encryption_key_id             = aws_kms_key.terraform_secrets.key_id
  secret_id                     = aws_secretsmanager_secret.secret[each.key].id
  encrypted_secret_value        = each.value.encrypted_secret_value
  encrypted_secret_value_file   = each.value.encrypted_secret_value_file
  encrypted_data_key            = each.value.encrypted_data_key
  encrypted_data_key_file       = each.value.encrypted_data_key_file
  binary                        = each.value.binary
  aws_cli_config                = var.aws_cli_config
  assume_role                   = var.assume_role
  assume_role_with_web_identity = var.assume_role_with_web_identity
}
