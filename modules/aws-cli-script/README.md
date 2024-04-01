# AWS CLI Ccript Terraform Module

This module allows you to run a local-exec script with the AWS CLI configured similar to how you would configure a provisioner.
Optionally, a role can also be assumed before running the provided command.

Note: No actions will be taken on destroy. Destroy provisioners do not have access to variables and so the AWS CLI cannot be safely configured. 

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [terraform_data.aws_cli_script](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role"></a> [assume\_role](#input\_assume\_role) | Details of role to assume before running script. <br><br>Fields:<br>  role\_arn: ARN of the role to assume<br>  session\_name: name of the session<br>  external\_id: external ID to use<br>  duration\_seconds: duration of the session | <pre>object({<br>    role_arn         = string<br>    session_name     = optional(string, "terraform-aws-cli-script")<br>    external_id      = optional(string, null)<br>    duration_seconds = optional(number, null)<br>  })</pre> | `null` | no |
| <a name="input_assume_role_with_web_identity"></a> [assume\_role\_with\_web\_identity](#input\_assume\_role\_with\_web\_identity) | AWS CLI assume role with web identity configuration, see:<br>https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html#cli-configure-role-oidc<br><br>Fields:<br>  role\_arn: ARN of the role to assume, passed in as AWS\_ROLE\_ARN<br>  session\_name: name of the session, passed in as AWS\_SESSION\_NAME<br>  web\_identity\_token\_file: path to the web identity token file, passed in as AWS\_WEB\_IDENTITY\_TOKEN\_FILE | <pre>object({<br>    role_arn                = string<br>    session_name            = optional(string, "terraform-aws-cli-script")<br>    web_identity_token_file = string<br>  })</pre> | `null` | no |
| <a name="input_aws_cli_config"></a> [aws\_cli\_config](#input\_aws\_cli\_config) | AWS CLI configuration, see:<br>https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html<br><br>Fields:<br>  profile: configuraiton profile to use, passed in as AWS\_PROFILE<br>  region: region to use, passed in as AWS\_REGION<br>  config\_file: path to the CLI configuration file, passed in as AWS\_CONFIG\_FILE<br>  shared\_credentials\_file: path to the shared credentials file, passed in as AWS\_SHARED\_CREDENTIALS\_FILE | <pre>object({<br>    profile                 = optional(string, null)<br>    region                  = optional(string, null)<br>    config_file             = optional(string, null)<br>    shared_credentials_file = optional(string, null)<br>  })</pre> | `null` | no |
| <a name="input_command"></a> [command](#input\_command) | Command to execute. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment variables to set for the command. | `map(string)` | `{}` | no |
| <a name="input_triggers_replace"></a> [triggers\_replace](#input\_triggers\_replace) | List of triggers to force replace the resource. | `list(string)` | `[]` | no |
| <a name="input_validate_account_id_against_provider"></a> [validate\_account\_id\_against\_provider](#input\_validate\_account\_id\_against\_provider) | Whether to validate the AWS CLI account ID against the given Terraform provider's account ID. | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->