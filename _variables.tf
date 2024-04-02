variable "encrypt_principals" {
  description = "List of additional AWS principals that can encrypt using the deployed KMS key. Ignored if key_policy is set."
  type        = list(string)
  default     = []
}

variable "decrypt_principals" {
  description = "List of additional AWS principals that can decrypt using the deployed KMS key. Ignored if key_policy is set."
  type        = list(string)
  default     = []
}

variable "key_policy" {
  description = "KMS key policy to use. If not set, a default policy is used."
  type        = string
  default     = null
}

variable "key_deletion_window_in_days" {
  description = "Duration in days after which the KMS key is deleted after destruction of the resource."
  type        = number
  default     = null
}

variable "alias_name" {
  description = "Name of the KMS alias to create."
  type        = string
  default     = "terraform-secrets"
}

variable "secrets" {
  description = <<-EOF
    List of secrets to create in AWS Secrets Manager. 
    One of encrypted_secret_value or encrypted_secret_value_file is required.

    fields:
      name: Name of the secret to be created.
      description: Description of the secret.
      encrypted_secret_value: Base64 encoded secret value that has been pre-encrypted using aws-encryption-cli.
      encrypted_secret_value_file: Path to base64 encoded secret file that has been pre-encrypted using aws-encryption-cli.
      policy: Resource based policy to attach to the secret.
      recovery_window_in_days: Number of days that AWS Secrets Manager waits before it can delete a secret.
      secret_kms_key_id: KMS key ID that will be configured for the secret.
  EOF
  type = list(object({
    name                        = optional(string, null)
    description                 = optional(string, null)
    policy                      = optional(string, null)
    recovery_window_in_days     = optional(number, null)
    secret_kms_key_id           = optional(string, null)
    encrypted_secret_value      = optional(string, null)
    encrypted_secret_value_file = optional(string, null)
    binary                      = optional(bool, false)
  }))
  default = []
}

variable "aws_cli_config" {
  description = <<-EOF
    AWS CLI configuration, see:
    https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html

    Fields:
      profile: configuraiton profile to use, passed in as AWS_PROFILE
      region: region to use, passed in as AWS_REGION
      config_file: path to the CLI configuration file, passed in as AWS_CONFIG_FILE
      shared_credentials_file: path to the shared credentials file, passed in as AWS_SHARED_CREDENTIALS_FILE
  EOF
  type = object({
    profile                 = optional(string, null)
    region                  = optional(string, null)
    config_file             = optional(string, null)
    shared_credentials_file = optional(string, null)
  })
  default = null
}

variable "assume_role_with_web_identity" {
  description = <<-EOF
    AWS CLI assume role with web identity configuration, see:
    https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html#cli-configure-role-oidc

    Fields:
      role_arn: ARN of the role to assume, passed in as AWS_ROLE_ARN
      session_name: name of the session, passed in as AWS_SESSION_NAME
      web_identity_token_file: path to the web identity token file, passed in as AWS_WEB_IDENTITY_TOKEN_FILE
  EOF
  type = object({
    role_arn                = string
    session_name            = optional(string, "terraform-aws-cli-script")
    web_identity_token_file = string
  })
  default = null
}

variable "assume_role" {
  description = <<-EOF
    Details of role to assume before running script. 

    Fields:
      role_arn: ARN of the role to assume
      session_name: name of the session
      external_id: external ID to use
      duration_seconds: duration of the session
  EOF
  type = object({
    role_arn         = string
    session_name     = optional(string, "terraform-aws-cli-script")
    external_id      = optional(string, null)
    duration_seconds = optional(number, null)
  })
  default = null
}
