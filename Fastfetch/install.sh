#!/usr/bin/env bash
#
# Install one of the fastfetch configs into ~/.config/fastfetch/config.jsonc
#
# Usage:
#   ./install.sh          # interactive menu
#   ./install.sh 1        # install config1.jsonc
#   ./install.sh 2        # install config2.jsonc
#
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch"
DEST_FILE="$DEST_DIR/config.jsonc"

usage() {
    cat <<EOF
Usage: ${0##*/} [1|2]

  1  config1.jsonc  - minimal, boxed modules with a small ASCII logo
  2  config2.jsonc  - sectioned (Hardware / Software / Uptime) with the builtin logo

Installs to: $DEST_FILE
EOF
}

config_path() {
    case "$1" in
        1) printf '%s\n' "$SCRIPT_DIR/config1.jsonc" ;;
        2) printf '%s\n' "$SCRIPT_DIR/config2.jsonc" ;;
        *) return 1 ;;
    esac
}

install_config() {
    local choice="$1" src
    src="$(config_path "$choice")" || {
        printf 'Error: unknown config "%s" (expected 1 or 2)\n' "$choice" >&2
        usage >&2
        exit 1
    }

    if [ ! -f "$src" ]; then
        printf 'Error: %s not found\n' "$src" >&2
        exit 1
    fi

    mkdir -p "$DEST_DIR"

    if [ -f "$DEST_FILE" ]; then
        local backup
        backup="$DEST_FILE.bak.$(date +%Y%m%d%H%M%S)"
        cp -f "$DEST_FILE" "$backup"
        printf 'Existing config backed up to %s\n' "$backup"
    fi

    install -m 644 "$src" "$DEST_FILE"

    printf 'Installed %s -> %s\n' "${src##*/}" "$DEST_FILE"

    if command -v fastfetch >/dev/null 2>&1; then
        printf '\nRun `fastfetch` to try it out.\n'
    else
        printf '\nfastfetch is not installed. See https://github.com/fastfetch-cli/fastfetch\n'
    fi
}

main() {
    local choice="${1:-}"

    case "$choice" in
        -h|--help)
            usage
            return 0
            ;;
        1|2) ;;
        '') ;;
        *)
            usage >&2
            exit 1
            ;;
    esac

    if [ -z "$choice" ]; then
        printf 'fastfetch config installer\n\n'
        printf '  1) config1 - minimal boxed modules, small ASCII logo\n'
        printf '  2) config2 - Hardware / Software / Uptime sections, builtin logo\n\n'
        printf 'Choose a config [1-2]: '

        if ! read -r choice; then
            printf '\nAborted.\n'
            exit 1
        fi
    fi

    install_config "$choice"
}

main "$@"
