#!/bin/bash
# Current directory of the script
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# Directory of the backup files
backup_dir=$1
# Name of the checksum file
checksum_file="$current_dir/checksum_caddy"

#-------------------------------------------------------------------------------
# CONFIGURATION FILE
#-------------------------------------------------------------------------------

config="$current_dir/caddy.config"

# Generating config file if non-existent
if [[ ! -f "$config" ]]; then
  # Creating the caddy.config file
  touch "$config"
  # Appending default config to caddy.config
  {
    echo "caddyfile_dir=\"/etc/Caddy/Caddyfile\""
    echo "zip_file_name=\"Caddy.zip\""
  } >>"$config"
fi

declare caddyfile_dir
declare zip_file_name

# shellcheck source=caddy.config
source "$config"

#-------------------------------------------------------------------------------
# BACKING UP FILES
#-------------------------------------------------------------------------------

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
  # Zipping the Caddyfile config
  zip "$backup_dir/$zip_file_name" "$caddyfile_dir"
fi
