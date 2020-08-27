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
  -s zip_file_name="Caddy.zip"

# Declaring variables to be sourced later ↓
declare caddyfile_dir
declare zip_file_name

# shellcheck source=caddy/caddy.config
source "$config_file"

#-------------------------------------------------------------------------------
# BACKING UP FILES
#-------------------------------------------------------------------------------

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
  # Zipping the Caddyfile config
  zip "$backup_dir/$zip_file_name" "$caddyfile_dir"
fi
