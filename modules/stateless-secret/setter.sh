#!/bin/bash
set -e
set -o pipefail

function _info() {
  echo "[stateless-secret module] INFO: $1"
}

function _error() {
  echo "" 1>&2
  echo "[stateless-secret module] ERROR: $1" 1>&2
  return 1
}

_info "Checking dependencies..."
command -v aws > /dev/null || _error "aws is required to run this script."
command -v base64 > /dev/null || _error "base64 is required to run this script."
command -v aws-encryption-cli > /dev/null || _error "aws-encryption-cli is required to run this script."
_info "All dependencies are met."

if [ -n "$ENCRYPTED_SECRET_VALUE" ] && [ -n "$ENCRYPTED_SECRET_VALUE_FILE" ]; then
  _error "Both encrypted_secret_value and encrypted_secret_value_file are set. Only one should be set."
fi

[ -n "$ENCRYPTED_SECRET_VALUE_FILE" ] && ENCRYPTED_SECRET_VALUE="$(cat "$ENCRYPTED_SECRET_VALUE_FILE")"

_info "Decrypting secret value with key '$KEY_ID'..."
DECRYPTED_SECRET_VALUE_B64="$(
  echo "$ENCRYPTED_SECRET_VALUE" \
  | aws-encryption-cli \
    --decrypt \
    --wrapping-keys "key=$KEY_ID" \
    --suppress-metadata \
    --input - \
    --decode \
    --output - \
    --encode
)" || _error "Failed to decrypt secret value with key '$KEY_ID'."
_info "Secret value decrypted successfully."

_info "Storing decrypted secret value in secret '$SECRET_ID'..."
if [ "$IS_BINARY" = "true" ]; then
  VERSION_ID="$(
    aws secretsmanager put-secret-value \
      --secret-id "$SECRET_ID" \
      --secret-binary fileb://<(echo "$DECRYPTED_SECRET_VALUE_B64" | base64 -d) \
      --query 'VersionId' \
      --output text
  )" || _error "Failed to store decrypted secret value in secret '$SECRET_ID' as binary. Ensure the secret referenced by secret_id exists and that the configured AWS principal has permissions to write to it."
else
  VERSION_ID="$(
    aws secretsmanager put-secret-value \
      --secret-id "$SECRET_ID" \
      --secret-string file://<(echo "$DECRYPTED_SECRET_VALUE_B64" | base64 -d) \
      --query 'VersionId' \
      --output text
  )" || _error "Failed to store decrypted secret value in secret '$SECRET_ID' as string. Ensure the secret referenced by secret_id exists and that the configured AWS principal has permissions to write to it."
fi
_info "Successfully set secret value for '$SECRET_ID' with version '$VERSION_ID'."
