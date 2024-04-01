#!/bin/bash
set -e
set -o pipefail

function _info() {
  echo "[aws-cli-script module] INFO: $1" 1>&2
}

function _error() {
  echo "" 1>&2
  echo "[aws-cli-script module] ERROR: $1" 1>&2
  return 1
}

_info "Checking dependencies..."
command -v aws > /dev/null || _error "AWS CLI is required to run this script."
_info "All dependencies are met."

_info "Checking ambient AWS configuration is valid..."
aws sts get-caller-identity --query 'Account' --output text > /dev/null || _error "Failed to authenticate with AWS. Check values used for aws_cli_config"
_info "Succesfully authenticated with AWS."

if [ -n "$ASSUME_ROLE_ARN" ]; then
  _info "Assuming role '$ASSUME_ROLE_ARN'..."
  ASSUME_ROLE_RESPONSE="$(
    aws sts assume-role \
      --role-arn "$ASSUME_ROLE_ARN" \
      --role-session-name "$ASSUME_ROLE_SESSION_NAME" \
      $([ -n "$ASSUME_ROLE_EXTERNAL_ID" ] && echo "--external-id" "$ASSUME_ROLE_EXTERNAL_ID" ) \
      $([ -n "$ASSUME_ROLE_DURATION_SECONDS" ] && echo "--duration-seconds" "$ASSUME_ROLE_DURATION_SECONDS") \
      --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
      --output text
  )" || _error "Failed to assume role '$ASSUME_ROLE_ARN'. Ensure the role exists and the configured AWS principal has permissions to assume it."
  export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" $ASSUME_ROLE_RESPONSE) # Word splitting is intentional
  _info "Assumed role '$ASSUME_ROLE_ARN'..."
fi
if [ -n "$PROVIDER_ACCOUNT_ID" ]; then
  _info "Checking configured AWS account matches provider configuration..."
  AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query 'Account' --output text)" || _error "Failed to authenticate with AWS."
  if [ "$AWS_ACCOUNT_ID" != "$PROVIDER_ACCOUNT_ID" ]; then
    _error "Authenticated AWS account '$AWS_ACCOUNT_ID' does not match provider configuration '$PROVIDER_ACCOUNT_ID'."
  fi
  _info "Successfully authenticated with AWS account '$AWS_ACCOUNT_ID'."
fi
echo "$ASSUME_ROLE_RESPONSE"