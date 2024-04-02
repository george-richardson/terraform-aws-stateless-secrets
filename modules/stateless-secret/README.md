# Stateless Secret Terraform Module

A module for populating an `aws_secretsmanager_secret`'s value, without saving the value to state. 
Uses the AWS CLI to set the secret value, which must be configured separately to Terraform's AWS provider.

See the [root README](../../README.md) for limitations, and considerations of use.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_setter"></a> [setter](#module\_setter) | ../aws-cli-script | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role"></a> [assume\_role](#input\_assume\_role) | Details of role to assume before running script. <br><br>Fields:<br>  role\_arn: ARN of the role to assume<br>  session\_name: name of the session<br>  external\_id: external ID to use<br>  duration\_seconds: duration of the session | <pre>object({<br>    role_arn         = string<br>    session_name     = optional(string, "terraform-aws-cli-script")<br>    external_id      = optional(string, null)<br>    duration_seconds = optional(number, null)<br>  })</pre> | `null` | no |
| <a name="input_assume_role_with_web_identity"></a> [assume\_role\_with\_web\_identity](#input\_assume\_role\_with\_web\_identity) | AWS CLI assume role with web identity configuration, see:<br>https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html#cli-configure-role-oidc<br><br>Fields:<br>  role\_arn: ARN of the role to assume, passed in as AWS\_ROLE\_ARN<br>  session\_name: name of the session, passed in as AWS\_SESSION\_NAME<br>  web\_identity\_token\_file: path to the web identity token file, passed in as AWS\_WEB\_IDENTITY\_TOKEN\_FILE | <pre>object({<br>    role_arn                = string<br>    session_name            = optional(string, "terraform-aws-cli-script")<br>    web_identity_token_file = string<br>  })</pre> | `null` | no |
| <a name="input_aws_cli_config"></a> [aws\_cli\_config](#input\_aws\_cli\_config) | AWS CLI configuration, see:<br>https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html<br><br>Fields:<br>  profile: configuraiton profile to use, passed in as AWS\_PROFILE<br>  region: region to use, passed in as AWS\_REGION<br>  config\_file: path to the CLI configuration file, passed in as AWS\_CONFIG\_FILE<br>  shared\_credentials\_file: path to the shared credentials file, passed in as AWS\_SHARED\_CREDENTIALS\_FILE | <pre>object({<br>    profile                 = optional(string, null)<br>    region                  = optional(string, null)<br>    config_file             = optional(string, null)<br>    shared_credentials_file = optional(string, null)<br>  })</pre> | `null` | no |
| <a name="input_binary"></a> [binary](#input\_binary) | Whether the secret value is binary data.<br>Binary values cannot be retrieved via the AWS Management Console. | `bool` | `false` | no |
| <a name="input_encrypted_secret_value"></a> [encrypted\_secret\_value](#input\_encrypted\_secret\_value) | Base64 encoded secret value that has been pre-encrypted using aws-encryption-cli.<br>Required if encrypted\_secret\_value\_file is not set.<br>If encryption\_key\_id is set, this value must be encrypted with corresponding key. | `string` | `null` | no |
| <a name="input_encrypted_secret_value_file"></a> [encrypted\_secret\_value\_file](#input\_encrypted\_secret\_value\_file) | Path to base64 encoded secret file that has been pre-encrypted using aws-encryption-cli.<br>Required if encrypted\_secret\_value is not set.<br>If encryption\_key\_id is set, this value must be encrypted with corresponding key. | `string` | `null` | no |
| <a name="input_encryption_key_id"></a> [encryption\_key\_id](#input\_encryption\_key\_id) | ID of the KMS key used to encrypt the secret value or data key. | `string` | `null` | no |
| <a name="input_secret_id"></a> [secret\_id](#input\_secret\_id) | ID of the secret to populate. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->