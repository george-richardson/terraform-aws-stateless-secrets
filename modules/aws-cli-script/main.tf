data "aws_caller_identity" "current" {}

resource "terraform_data" "aws_cli_script" {
  triggers_replace = var.triggers_replace

  provisioner "local-exec" {
    command = <<-EOF
      ASSUME_ROLE_RESPONSE="$(${path.module}/setup.sh)" || exit 1
      [ -n "$ASSUME_ROLE_RESPONSE" ] && export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" $ASSUME_ROLE_RESPONSE);
      ${var.command}
    EOF

    environment = merge({
      PROVIDER_ACCOUNT_ID = var.validate_account_id_against_provider ? data.aws_caller_identity.current.account_id : null

      # AWS CLI configuration
      # https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html
      AWS_PROFILE                 = try(var.aws_cli_config.profile, null)
      AWS_REGION                  = try(var.aws_cli_config.region, null)
      AWS_CONFIG_FILE             = try(var.aws_cli_config.config_file, null)
      AWS_SHARED_CREDENTIALS_FILE = try(var.aws_cli_config.shared_credentials_file, null)

      # Assume role with web identity config (handled by CLI itself)
      # Defined separately to match provider configuration style
      AWS_ROLE_ARN                = try(var.assume_role_with_web_identity.role_arn, null)
      AWS_SESSION_NAME            = try(var.assume_role_with_web_identity.session_name, null)
      AWS_WEB_IDENTITY_TOKEN_FILE = try(var.assume_role_with_web_identity.web_identity_token_file, null)

      # Assume role config 
      # Handled by script
      ASSUME_ROLE_ARN              = try(var.assume_role.role_arn, null)
      ASSUME_ROLE_SESSION_NAME     = try(var.assume_role.session_name, null)
      ASSUME_ROLE_EXTERNAL_ID      = try(var.assume_role.external_id, null)
      ASSUME_ROLE_DURATION_SECONDS = try(var.assume_role.duration_seconds, null)
    }, var.environment)
  }
}
