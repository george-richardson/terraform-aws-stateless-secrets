variable "command" {
  description = "Command to execute."
  type        = string
}

variable "triggers_replace" {
  description = "List of triggers to force replace the resource."
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment variables to set for the command."
  type        = map(string)
  default     = {}
}

variable "validate_account_id_against_provider" {
  description = "Whether to validate the AWS CLI account ID against the given Terraform provider's account ID."
  type        = bool
  default     = true
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
