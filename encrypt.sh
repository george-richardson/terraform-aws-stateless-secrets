#!/bin/bash

set -e

function usage() {
  cat <<EOF
Usage: $0 [ -e ] -k KEY_ARN -f FILE
  -k KEY_ID -- Key ID, key ARN, alias name, or alias ARN of the KMS key to use to encrypt
  -f FILE   -- Path to file to encrypt
  -e        -- Use envelope encryption, suitable for files larger than 4,096 bytes
EOF
}

function exit_abnormal() {
  usage
  exit 1
}

ENVELOPE_ENCRYPTION="false"

while getopts "ek:f:" options; do
  case "${options}" in
    k)
      KEY_ID=${OPTARG}
      ;;
    f)
      FILE=${OPTARG}
      ;;
    e)
      ENVELOPE_ENCRYPTION="true"
      ;;
    *)
      exit_abnormal
      ;;
  esac
done

if [ -z "$KEY_ID" ] || [ -z "$FILE" ]; then
  exit_abnormal
fi

ENCRYPTED_FILE_PATH="$FILE.enc"
ENCRYPTED_DATA_KEY_FILE_PATH="$FILE.enc.key"

function encrypt() {
  ENCRYPTED_VALUE="$(
    aws kms encrypt \
      --key-id "$KEY_ID" \
      --plaintext "file://"<(openssl enc -e -a -in "$FILE") \
      --query 'CiphertextBlob' \
      --output text
  )"
  echo "$ENCRYPTED_VALUE" > "$ENCRYPTED_FILE_PATH"
}

function envelope_encrypt() {
  DATA_KEY_RESPONSE="$(aws kms generate-data-key \
    --key-id "$KEY_ID" \
    --key-spec "AES_256" \
    --query "[Plaintext,CiphertextBlob]" \
    --output text
  )"
  declare $(printf "PLAINTEXT_DATA_KEY=%s ENCRYPTED_DATA_KEY=%s" $DATA_KEY_RESPONSE);
  openssl enc -e -a -aes256 -pbkdf2 -kfile <(echo "$PLAINTEXT_DATA_KEY") -in "$FILE" -out "$ENCRYPTED_FILE_PATH"
  echo "$ENCRYPTED_DATA_KEY" > "$ENCRYPTED_DATA_KEY_FILE_PATH"
}

if [ "$ENVELOPE_ENCRYPTION" = "true" ]; then
  envelope_encrypt
  echo "Encrypted data key: $ENCRYPTED_DATA_KEY_FILE_PATH"
else
  encrypt
fi
echo "Encrypted file: $ENCRYPTED_FILE_PATH"
echo "Success"
