#!/bin/bash
# Generate config directory and file if non-existent.
#
# Example usage:
# generate_config -f /path/to/caddy/caddy.config \
#   -i caddy_dir="/etc/caddy/Caddyfile"
#   -i zip_file_name="Caddy.zip"
function generate_config() {
  # Defining local variables (the "g" prefix is required to avoid conflicts)
  local g_arg g_config_file g_config_items=()

  # Function named arguments
  # -f for "config File"
  # -s for "String" item
  # -a for "Array" item
  while getopts ":f:s:a:" g_arg; do
    case ${g_arg} in
    f) g_config_file=${OPTARG} ;;
    s) g_config_items+=(["${OPTARG}"]="string") ;;
    a) g_config_items+=(["${OPTARG}"]="array") ;;
    \?)
      echo "Usage: generate_config [-f -s -a]"
      return 1
      ;;
    esac
  done

  # Creating the config directory if non-existent
  if [ ! -d "$g_config_file" ]; then
    mkdir -p "$(dirname "$g_config_file")"
  fi

  # Creating the config file if non-existent
  if [[ ! -f "$g_config_file" ]]; then
    touch "$g_config_file"
    {
      echo "#!/bin/bash"
      echo -n "# IMPORTANT: only change the value between the"
      echo "\"quotation marks\" or \"()\"."
    } >"$g_config_file"

    local len=${#g_config_items[@]} # ← Length of the array

    # Adding each config item specified with the -s or -a argument
    for ((i = 0; i < $len; i++)); do
      if [[ "${g_config_items[$i]}" == "string" ]]; then
        # Appending item to file and wrapping value around quotation marks
        echo "export ${!g_config_items[$i]}" | sed 's/=/=\"/; s/$/\"/' \
          >>"$g_config_file"
      elif [[ "${g_config_items[$i]}" == "array" ]]; then
        echo "export ${!g_config_items[$i]}" >>"$g_config_file"
      fi
    done

    for item in "${g_config_items[@]}"; do
      # Appending config item to file and wrapping value around quotation marks
      echo "export $item" | sed 's/=/=\"/; s/$/\"/' >>"$g_config_file"
    done
  fi
}
