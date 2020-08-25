#!/bin/bash
# Create an encrypted zip archive with GnuPG.
# The first argument must be the name of the zip file, followed by the other
# arguments related entirely to the `zip` command.
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
  file_name=$1

  # If the first parameter does NOT end with the .zip extension
  if [[ "$file_name.zip" != *.zip ]]; then
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

  # Removing the .zip extension from the file name
  file_name=${file_name%.zip}

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

  # Creating the --recipient parameter for each recipient
  recipients_param=""
  for recipient in "${recipients[@]}"; do
    recipients_param+="--recipient $recipient "
  done

  # Encrypting zip archive
  # shellcheck disable=SC2086
  gpg --output "$file_name.gpg" --encrypt --sign $recipients_param "$file_name.zip"

  # Removing zip and only keeping the encrypted file
  rm "$file_name.zip"
}
