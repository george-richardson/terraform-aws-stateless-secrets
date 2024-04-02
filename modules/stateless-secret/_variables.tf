variable "secret_id" {
  description = "ID of the secret to populate."
  type        = string
}

variable "encrypted_secret_value" {
  description = <<-EOF
    Base64 encoded secret value that has been pre-encrypted using aws-encryption-cli.
    Required if encrypted_secret_value_file is not set.
    If encryption_key_id is set, this value must be encrypted with corresponding key.
  EOF

  type    = string
  default = null
}

variable "encrypted_secret_value_file" {
  description = <<-EOF
    Path to base64 encoded secret file that has been pre-encrypted using aws-encryption-cli.
    Required if encrypted_secret_value is not set.
    If encryption_key_id is set, this value must be encrypted with corresponding key.
  EOF
  type        = string
  default     = null
}

variable "binary" {
  description = <<-EOF
    Whether the secret value is binary data.
    Binary values cannot be retrieved via the AWS Management Console.
  EOF

  type    = bool
  default = false
}

variable "encryption_key_id" {
  description = "ID of the KMS key used to encrypt the secret value or data key."
  type        = string
  default     = null
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
