module "setter" {
  source = "../aws-cli-script"

  command                       = "${path.module}/setter.sh"
  aws_cli_config                = var.aws_cli_config
  assume_role                   = var.assume_role
  assume_role_with_web_identity = var.assume_role_with_web_identity

  environment = {
    SECRET_ID                   = var.secret_id
    ENCRYPTED_SECRET_VALUE      = var.encrypted_secret_value
    ENCRYPTED_SECRET_VALUE_FILE = var.encrypted_secret_value_file
    IS_BINARY                   = var.binary
    KEY_ID                      = var.encryption_key_id
  }

  triggers_replace = [
    "Encrypted Secret Hash: ${var.encrypted_secret_value_file != null ? filemd5(var.encrypted_secret_value_file) : md5(var.encrypted_secret_value)}",
    "Secret ID: ${var.secret_id}",
    "Is Binary: ${var.binary}",
  ]
}
