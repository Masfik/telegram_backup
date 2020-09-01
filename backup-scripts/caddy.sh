#!/bin/bash
# Current directory of the script
declare -r current_dir=$1
# Directory of the backup files
declare -r backup_dir=$2
# Directory of the config files
declare -r config_dir="$current_dir/caddy"

#-------------------------------------------------------------------------------
# CONFIGURATION FILE
#-------------------------------------------------------------------------------

# shellcheck source=utils/generate_config.sh
source "$3/generate_config.sh" --source-only

declare -r config_file="$config_dir/caddy.config"

# Generating default config folder and file if non-existent
generate_config -f "$config_file" \
  -s caddyfile_dir="/etc/caddy/Caddyfile" \
  -s service_file="/etc/systemd/system/caddy.service" \
  -s file_name="Caddy"

# Declaring variables to be sourced later ↓
declare caddyfile_dir
declare service_file
declare file_name

# shellcheck source=caddy/caddy.config
source "$config_file" --source-only

#-------------------------------------------------------------------------------
# BACKING UP FILES
#-------------------------------------------------------------------------------

# shellcheck source=utils/file_encryption.sh
source "$3/file_encryption.sh" --source-only

# Path of the checksum file
declare -r checksum_file="$config_dir/checksum_caddy"

# Creating the checksum file if non-existent
touch "$checksum_file"
# Reading the saved checksum of the Caddyfile
previous_checksum=$(head -n 1 "$checksum_file")
# New checksum of the file to verify changes
new_checksum=$(sha256sum "$caddyfile_dir")

if [[ "$previous_checksum" == "$new_checksum" ]]; then
  echo "[Caddy] No changes detected."
else
  # Saving the new checksum to the file
  echo "$new_checksum" >"$checksum_file"

  # shellcheck source=../tg-backup.config
  source "$5" --source only; declare -a gpg_recipients

  # Zipping the Caddyfile config
  encrypted_zip "$backup_dir/$file_name.zip" \
    "$caddyfile_dir" \
    "$service_file" \
    \
    --gpg-recipients "${gpg_recipients[@]}"
fi
