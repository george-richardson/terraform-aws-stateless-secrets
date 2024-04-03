# Terraform AWS Stateless Secrets Module

A module for creating AWS Secrets Manager Secrets without storing their values in Terraform's state. This is done by 
pre-encrypting secrets using `aws-encryption-cli`, then at `apply` stage using a `local-exec` provisioner to decrypt
them and set the Secrets Manager secret value. Only a hash of the _encrypted_ value is stored in state. 

There are two scenarios where you may want this, with the assumption that you _want_ to manage secret values from 
Terraform:

1. You want to provide state access to developers without granting them the ability to get secret values. (e.g. run 
   a plan on a non-dev environment).
2. You want to allow developers to set secrets without granting them the ability to read them.

However, this module has limitations and drawbacks detailed below which you should read before use. When configured 
correctly this can be a safer replacement for `aws_secretsmanager_secret_version`, but does not solve all functional or 
security issues related to managing secrets via infrastucture as code. Use at your own risk.  

## Usage

TBD

### Basic Usage

TBD

#### Encrypting a secret

#### AWS Configuration

#### Dependencies

### Automatically creating secrets from a directory

### Usage in an automation pipeline



### Setting a single secret

## Choosing suitable permissions for KMS keys and secrets

It is extremely important to ensure that principals are given least privilege access to secrets and keys. Care should be
taken to ensure permissions granted for using KMS keys and Secrets Manager secret values are done so in line with the 
principle of least privilege, and any legal or compliance requirements that may apply. 

The below sections describe the permissions a principal will need to perform various actions related to this module. 
Consider using explicit deny rules in IAM, SCP, or resource based policies to _prevent_ principals from accidentally 
being granted more access than they require.

### Terraform plan

To run a Terraform `plan` using this module (or Terraform apply that does not need to update secret values), the 
following permissions are needed:



### Terraform apply

To run a Terraform `apply` using this module which will set new secret values, the following permissions are needed:



### Pre-encryption

To pre-encrypt a secret using this module, the following permissions are needed:


Note you can choose to allow principals to pre-encrypt secrets without granting them the `apply` permissions. This could
be useful if you have automated `terraform apply`, effectively allowing engineers to set values via automation without
granting the ability to decrypt values themselves.

## Drawbacks

You should understand the following points before deciding to use this module. 

1. This module is _stateless_, therefore it cannot detect drift. Changes to secrets passed in to the module will be 
   detected and updated appropriately. Changes to secret values made outside of Terraform (e.g. via the AWS console) 
   will not be detected or reconciled.
2. This module uses `local_exec` provisioners and bash scripts (see dependencies above). This reduces the portability
   of your Terraform configuration. For example, this module would be difficult to run on Windows. 
3. The "setter" `terraform_data` resource which is used to actually run the local script has no destroy behaviour. 
   Destroying this resource without destroying or changing the value of the underlying `aws_secrets_manager_secret` 
   resource doesn't change or wipe the secret value.

## Security Considerations

You should understand the following points before deciding to use this module. 

1. This module does not remove the need for storing a second copy of a secret. When using 
   `aws_secretsmanager_secret_version` this second copy would be stored in Terraform's state file, accessible to anyone
   with access to that state. This module instead relies on passing in a value encrypted by a KMS key, which can have 
   finer grained access controls. However, there is still at least a second copy of every secret, its location has just 
   moved. 
2. This module does not remove a single point of failure for secret compromises. When using 
   `aws_secretsmanager_secret_version` this single point of failure is granting access to the Terraform state file. 
   When using this module the single point of failure is granting `kms:Decrypt` permission on the KMS key.
3. When using this module you may be tempted to store your encrypted secrets in version control. If you do this, 
   understand that granting someone `kms:Decrypt` on the KMS key grants them access to all values _ever_ encrypted with 
   that key.
4. This module does not support automatic secret rotation by itself. If you can automatically rotate secrets, you
   should endeavour to do that instead of using this module. If you do use this module, you should still manually rotate
   your secrets. 
5. Be careful not to create privilge escalation opportunities when running this module via automation. e.g. granting 
   an automated pull request triggered `plan` run more priviliges than the user who triggered it, allowing them to 
   retrieve values by adding Terraform `output`s to a branch.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_secrets"></a> [secrets](#module\_secrets) | ./modules/stateless-secret | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.terraform_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.terraform_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_secretsmanager_secret.secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.terraform_secrets_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name) | Name of the KMS alias to create. | `string` | `"terraform-secrets"` | no |
| <a name="input_assume_role"></a> [assume\_role](#input\_assume\_role) | Details of role to assume before running script. <br><br>Fields:<br>  role\_arn: ARN of the role to assume<br>  session\_name: name of the session<br>  external\_id: external ID to use<br>  duration\_seconds: duration of the session | <pre>object({<br>    role_arn         = string<br>    session_name     = optional(string, "terraform-aws-cli-script")<br>    external_id      = optional(string, null)<br>    duration_seconds = optional(number, null)<br>  })</pre> | `null` | no |
| <a name="input_assume_role_with_web_identity"></a> [assume\_role\_with\_web\_identity](#input\_assume\_role\_with\_web\_identity) | AWS CLI assume role with web identity configuration, see:<br>https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html#cli-configure-role-oidc<br><br>Fields:<br>  role\_arn: ARN of the role to assume, passed in as AWS\_ROLE\_ARN<br>  session\_name: name of the session, passed in as AWS\_SESSION\_NAME<br>  web\_identity\_token\_file: path to the web identity token file, passed in as AWS\_WEB\_IDENTITY\_TOKEN\_FILE | <pre>object({<br>    role_arn                = string<br>    session_name            = optional(string, "terraform-aws-cli-script")<br>    web_identity_token_file = string<br>  })</pre> | `null` | no |
| <a name="input_aws_cli_config"></a> [aws\_cli\_config](#input\_aws\_cli\_config) | AWS CLI configuration, see:<br>https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html<br><br>Fields:<br>  profile: configuraiton profile to use, passed in as AWS\_PROFILE<br>  region: region to use, passed in as AWS\_REGION<br>  config\_file: path to the CLI configuration file, passed in as AWS\_CONFIG\_FILE<br>  shared\_credentials\_file: path to the shared credentials file, passed in as AWS\_SHARED\_CREDENTIALS\_FILE | <pre>object({<br>    profile                 = optional(string, null)<br>    region                  = optional(string, null)<br>    config_file             = optional(string, null)<br>    shared_credentials_file = optional(string, null)<br>  })</pre> | `null` | no |
| <a name="input_decrypt_principals"></a> [decrypt\_principals](#input\_decrypt\_principals) | List of additional AWS principals that can decrypt using the deployed KMS key. Ignored if key\_policy is set. | `list(string)` | `[]` | no |
| <a name="input_encrypt_principals"></a> [encrypt\_principals](#input\_encrypt\_principals) | List of additional AWS principals that can encrypt using the deployed KMS key. Ignored if key\_policy is set. | `list(string)` | `[]` | no |
| <a name="input_key_deletion_window_in_days"></a> [key\_deletion\_window\_in\_days](#input\_key\_deletion\_window\_in\_days) | Duration in days after which the KMS key is deleted after destruction of the resource. | `number` | `null` | no |
| <a name="input_key_policy"></a> [key\_policy](#input\_key\_policy) | KMS key policy to use. If not set, a default policy is used. | `string` | `null` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secrets to create in AWS Secrets Manager. <br>One of encrypted\_secret\_value or encrypted\_secret\_value\_file is required.<br><br>fields:<br>  name: Name of the secret to be created.<br>  description: Description of the secret.<br>  encrypted\_secret\_value: Base64 encoded secret value that has been pre-encrypted using aws-encryption-cli.<br>  encrypted\_secret\_value\_file: Path to base64 encoded secret file that has been pre-encrypted using aws-encryption-cli.<br>  policy: Resource based policy to attach to the secret.<br>  recovery\_window\_in\_days: Number of days that AWS Secrets Manager waits before it can delete a secret.<br>  secret\_kms\_key\_id: KMS key ID that will be configured for the secret. | <pre>list(object({<br>    name                        = optional(string, null)<br>    description                 = optional(string, null)<br>    policy                      = optional(string, null)<br>    recovery_window_in_days     = optional(number, null)<br>    secret_kms_key_id           = optional(string, null)<br>    encrypted_secret_value      = optional(string, null)<br>    encrypted_secret_value_file = optional(string, null)<br>    binary                      = optional(bool, false)<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_alias_arn"></a> [kms\_alias\_arn](#output\_kms\_alias\_arn) | The ARN of the KMS alias to be used to encrypt secret value or data keys for secrets to be stored in version control. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key to be used to encrypt secret value or data keys for secrets to be stored in version control. |
| <a name="output_secret_arns"></a> [secret\_arns](#output\_secret\_arns) | Map of created secret's names to ARNs. |
<!-- END_TF_DOCS -->