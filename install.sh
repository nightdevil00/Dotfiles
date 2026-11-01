#!/usr/bin/env bash
#
# Install configurations from this repository.
#
#   ./install.sh                 interactive picker
#   ./install.sh hyprland [opts] Hyprland config -> ~/.config/hypr
#   ./install.sh niri [opts]     Niri + Noctalia config
#   ./install.sh fastfetch [n]   Fastfetch config picker
#   ./install.sh all [opts]      Hyprland + full Niri/Noctalia setup
#
# Options are passed through to the selected installer:
#   --dry-run, -n   show what would change, write nothing
#   --force, -f     overwrite without backups
#
# Fastfetch also keeps its own installer: ./Fastfetch/install.sh

set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: ${0##*/} [target] [options]

Targets:
  hyprland, hypr, h   Install the Hyprland config
  niri, n             Install the Niri + Noctalia config
  fastfetch, f        Install a Fastfetch layout
  all, a              Hyprland + full Niri/Noctalia setup

Options:
  --dry-run, -n       Show what would change, write nothing
  --force, -f         Overwrite without backups
  -h, --help          Show this help

With no target, an interactive picker is shown. With no target but options
such as --dry-run, the Hyprland installer is used for backward compatibility.
EOF
}

pick_interactively() {
  if [[ ! -t 0 ]]; then
    printf 'error: no target selected (use hyprland, niri, fastfetch, or all)\n' >&2
    usage >&2
    exit 1
  fi

  printf 'Dotfiles installer\n\n'
  printf '  1) Hyprland\n'
  printf '  2) Niri + Noctalia\n'
  printf '  3) Fastfetch\n'
  printf '  4) Hyprland + Niri/Noctalia\n'
  printf '\nChoose [1-4]: '

  local choice
  read -r choice || {
    printf '\nAborted.\n'
    exit 1
  }

  case "$choice" in
    1) exec "$ROOT/Hyprland/install.sh" ;;
    2) exec "$ROOT/Niri/install.sh" ;;
    3) exec "$ROOT/Fastfetch/install.sh" ;;
    4) exec "$ROOT/install.sh" all ;;
    *)
      printf 'error: invalid choice "%s"\n' "$choice" >&2
      exit 1
      ;;
  esac
}

(($# > 0)) || pick_interactively

target="$1"
shift

case "$target" in
  hyprland | hypr | h)
    exec "$ROOT/Hyprland/install.sh" "$@"
    ;;
  niri | n)
    exec "$ROOT/Niri/install.sh" "$@"
    ;;
  fastfetch | f)
    exec "$ROOT/Fastfetch/install.sh" "$@"
    ;;
  all | a)
    "$ROOT/Hyprland/install.sh" "$@"
    "$ROOT/Niri/install.sh" --all "$@"
    ;;
  -h | --help)
    usage
    ;;
  -*)
    # Older usage was `./install.sh --dry-run`, which meant Hyprland.
    exec "$ROOT/Hyprland/install.sh" "$target" "$@"
    ;;
  *)
    printf 'error: unknown target "%s"\n\n' "$target" >&2
    usage >&2
    exit 1
    ;;
esac
