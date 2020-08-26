#!/bin/bash
# Create an encrypted file with GnuPG.
# The first parameter is the file name.
# The second parameter must be --gpg-recipients, followed by a list of valid
# E-Mail addresses saved.
#
# Usage example:
# encrypt_file file.txt --gpg-recipients email1@domain.tld email2@domain.tld
function encrypt_file() {
  if [[ "$2" != "--gpg-recipients" ]]; then
    echo "The second argument is not --gpg-recipients."
    echo "Example: encrypt_file file.txt --gpg-recipients email@domain.tld"
    exit 1
  fi

  local file_path=$1
  local file_name="${file_path%%.*}" # ← Removing extension
  shift 2

  echo "$file_name"

  recipients_param=""
  for recipient in "$@"; do
    recipients_param+="--recipient $recipient "
  done

  # Encrypting file
  # shellcheck disable=SC2086
  gpg --output "$file_name.gpg" --encrypt --sign $recipients_param "$file_path"
}

# Create an encrypted zip archive with GnuPG.
# The first argument must be the name of the zip file (must end with .zip ext),
# followed by the other arguments related entirely to the `zip` command.
# The last few arguments must be related to gpg recipients.
# !!! THE ORDER IS IMPORTANT !!!
#
# Usage example (creating test.gpg):
# encrypted_zip test.zip -r \
#   /root/bw-data/db.sqlite3 \
#   /root/bw-data/attachments \
#   \
#   --gpg-recipients email1@domain.tld email2@domain.tld email3@domain.tld
function encrypted_zip() {
  local file_name=$1

  # If the first parameter does NOT end with the .zip extension
  if [[ "$file_name" != *.zip ]]; then
    echo "The first argument does not indicate a .zip file name."
    echo "Example: encrypted_zip test.zip ..."
    exit 1
  fi

  # If the arguments do NOT contain "--gpg-recipients "
  if [[ "'$*'" != *"--gpg-recipients "* ]]; then
    echo "No GPG recipients specified. Please indicate a list of recipients."
    echo "Example: encrypted_zip test.zip file.doc
      --gpg-recipients email@domain.tld"
    exit 1
  fi

  # Splitting function parameters into an array.
  # The first element will be dedicated to the zip command parameters.
  # The second element is dedicated to the gpg recipients.
  mapfile -t params < <(
    echo "${@}" | awk '{ gsub(/--gpg-recipients +/, "\n" ); print; }'
  )

  # shellcheck disable=SC2086
  zip ${params[0]}

  # Creating a "recipients" array using the space as the delimiter
  IFS=" " read -r -a recipients <<<"${params[1]}"

  # Encrypting ZIP archive
  encrypt_file "$file_name" --gpg-recipients "${recipients[@]}"

  # Removing zip and only keeping the encrypted file
  rm "$file_name"
}
