#!/bin/bash
# Current directory of the script
declare -r current_dir=$1
# Directory of the backup files
declare -r backup_dir=$2
# Directory of the config files
declare -r config_dir="$current_dir/iptables"

#-------------------------------------------------------------------------------
# CONFIGURATION FILE
#-------------------------------------------------------------------------------

# utils/generate_config.sh
# shellcheck disable=SC1090
source "$3/generate_config.sh" --source-only

declare -r config_file="$config_dir/iptables.config"

# Generating default config folder and file if non-existent
generate_config -f "$config_file" -s file_name="iptables"

declare file_name

# shellcheck disable=SC1090
source "$config_file" --source-only

#-------------------------------------------------------------------------------
# BACKING UP FILES
#-------------------------------------------------------------------------------

# utils/file_encryption.sh
# shellcheck disable=SC1090
source "$3/file_encryption.sh" --source-only

# Directory of the temporary files
declare -r tmp_dir=$4

# Exported rules
declare -r rules_file="$tmp_dir/iptables.rules"
# Path of the checksum file
declare -r checksum_file="$config_dir/checksum_iptables"

# Creating the rules and checksum file if non-existent
touch "$rules_file" "$checksum_file"
# Reading the saved checksum of the Caddyfile
previous_checksum=$(head -n 1 "$checksum_file")
# New checksum of the file to verify changes
new_checksum=$(sha256sum "$rules_file")

if [[ "$previous_checksum" == "$new_checksum" ]]; then
  echo "[iptables] No changes detected."
else
  # Saving iptables rules
  # Pipelines remove first and last lines from the stream (aka backup dates)
  iptables-save | tail -n +2 | head -n -1 >"$rules_file" # ← could be improved

  # Saving the new checksum to the file
  echo "$new_checksum" >"$checksum_file"

  # ../tg-backup.config
  # shellcheck disable=SC1090
  source "$5" --source only; declare -a gpg_recipients

  # Zipping rules
  encrypted_zip "$backup_dir/$file_name.zip" -j "$rules_file" \
    --gpg-recipients "${gpg_recipients[@]}"
fi
