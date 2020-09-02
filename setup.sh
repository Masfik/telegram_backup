#!/bin/bash
# Current directory of the script
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

#-------------------------------------------------------------------------------
# GPG CHECKS
#-------------------------------------------------------------------------------

# Running the gpg command once to allow ~/.gnupg/ folder generation
gpg --list-keys &>/dev/null # ← ignoring folder generation output

if [[ ! $(gpg --list-keys) ]]; then
  echo "No keys found. You need to import some GPG keys first."
  echo "Use 'gpg --import key.gpg' or generate a new one with" \
    "'gpg --full-gen-key'"
  exit 1
fi

#-------------------------------------------------------------------------------
# SETTING UP CONFIG VARIABLES
#-------------------------------------------------------------------------------

echo "Insert the token of the bot. If you currently don't have one, get in" \
  "touch with @BotFather on Telegram (https://t.me/BotFather) and follow its" \
  "instructions."

echo -n "Bot token: "; read -r BOT_TOKEN  # TODO: check if valid token
echo -n "Chat ID: "; read -r CHAT_ID      # TODO: check if valid chat ID

echo -n "Type a list of GPG key IDs or email addresses (separated by space): "
read -r recipients

# utils/generate_config.sh
# shellcheck disable=SC1090
source "$current_dir/utils/generate_config.sh" --source-only

# Generating config file with the provided variables
generate_config -f "$current_dir/tg-backup.config" \
  -s BOT_TOKEN="$BOT_TOKEN" \
  -s CHAT_ID="$CHAT_ID" \
  -a gpg_recipients="($recipients)"

echo "Setup completed!"
