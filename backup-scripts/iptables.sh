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

# shellcheck source=utils/generate_config.sh
source "$3/generate_config.sh" --source-only

declare -r config_file="$config_dir/iptables.config"

# Generating default config folder and file if non-existent
generate_config -f "$config_file" -s zip_file_name="iptables.zip"

declare zip_file_name

# shellcheck source=iptables/iptables.config
source "$config_file"

#-------------------------------------------------------------------------------
# BACKING UP FILES
#-------------------------------------------------------------------------------

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

  # Zipping rules
  zip "$backup_dir/$zip_file_name" "$rules_file"
fi
