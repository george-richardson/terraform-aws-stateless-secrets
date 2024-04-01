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
command -v openssl > /dev/null || _error "openssl is required to run this script."
_info "All dependencies are met."

function _decrypt() {
  _info "Decrypting secret value..."
  DECRYPTED_SECRET_VALUE_B64="$(
    aws kms decrypt \
      --ciphertext-blob "$ENCRYPTED_SECRET_VALUE" \
      $([ -n "$KEY_ID" ] && echo "--key-id" "$KEY_ID") \
      --query 'Plaintext' \
      --output text
  )" || _error "Failed to decrypt provided secret value. Ensure value for encrypted_secret_value is well formed and that the configured AWS principal has permissions to use the underlying KMS key."
  _info "Secret value decrypted successfully."
}

function _decrypt_with_data_key() {
  [ -n "$ENCRYPTED_DATA_KEY_FILE" ] && ENCRYPTED_DATA_KEY="$(cat "$ENCRYPTED_DATA_KEY_FILE")"
  [ -n "$ENCRYPTED_DATA_KEY" ] || _error "No encrypted data key provided. Either set encrypted_data_key or encrypted_data_key_file."

  _info "Decrypting data key..."
  DECRYPTED_DATA_KEY="$(
  aws kms decrypt \
    --ciphertext-blob "$ENCRYPTED_DATA_KEY" \
    $([ -n "$KEY_ID" ] && echo "--key-id" "$KEY_ID") \
    --query 'Plaintext' \
    --output text
  )" || _error "Failed to decrypt data key. Ensure value for encrypted_data_key is well formed and that the configured AWS principal has permissions to use the underlying KMS key."
  _info "Data key decrypted successfully."

  [ -n "$ENCRYPTED_SECRET_VALUE" ] || _error "No encrypted secret value provided. Either set encrypted_secret_value or encrypted_secret_value_file."
  DECRYPTED_SECRET_VALUE_B64="$(
    echo "$ENCRYPTED_SECRET_VALUE" \
    | openssl enc -d -a -aes256 -pbkdf2 -kfile <(echo "$DECRYPTED_DATA_KEY") \
    | openssl enc -e -a
  )" || _error "Failed to decrypt provided secret value using provided data key."
}

[ -n "$ENCRYPTED_SECRET_VALUE_FILE" ] && ENCRYPTED_SECRET_VALUE="$(cat "$ENCRYPTED_SECRET_VALUE_FILE")"

if [ -n "$ENCRYPTED_DATA_KEY" ] || [ -n "$ENCRYPTED_DATA_KEY_FILE" ]; then
  _decrypt_with_data_key
else
  _decrypt
fi

_info "Storing decrypted secret value in secret '$SECRET_ID'..."
if [ "$IS_BINARY" = "true" ]; then
  VERSION_ID="$(
    aws secretsmanager put-secret-value \
      --secret-id "$SECRET_ID" \
      --secret-binary fileb://<(echo "$DECRYPTED_SECRET_VALUE_B64" | openssl enc -d -a) \
      --query 'VersionId' \
      --output text
  )" || _error "Failed to store decrypted secret value in secret '$SECRET_ID' as binary. Ensure the secret referenced by secret_id exists and that the configured AWS principal has permissions to write to it."
else
  VERSION_ID="$(
    aws secretsmanager put-secret-value \
      --secret-id "$SECRET_ID" \
      --secret-string file://<(echo "$DECRYPTED_SECRET_VALUE_B64" | openssl enc -d -a) \
      --query 'VersionId' \
      --output text
  )" || _error "Failed to store decrypted secret value in secret '$SECRET_ID' as string. Ensure the secret referenced by secret_id exists and that the configured AWS principal has permissions to write to it."
fi
_info "Successfully set secret value for '$SECRET_ID' with version '$VERSION_ID'."
