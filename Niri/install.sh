#!/usr/bin/env bash
#
# Install the Niri + Noctalia configuration from this directory.
#
# Components can be selected interactively or with flags:
#
#   ./install.sh                 interactive picker
#   ./install.sh --all           install every component
#   ./install.sh --niri          Niri compositor config
#   ./install.sh --noctalia      Noctalia config + active settings
#   ./install.sh --clipboard     universal clipboard helper
#   ./install.sh --plugins       enabled community Noctalia plugins
#   ./install.sh --list          show components and destinations
#
# Options:
#   --dry-run, -n   show what would change, write nothing
#   --force, -f     overwrite without making backups
#   --no-reload     do not ask running niri/Noctalia to reload
#
# Existing files are backed up with a timestamp before being replaced. Files
# that are already identical are skipped.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
BIN_HOME="$HOME/.local/bin"

SRC_NIRI="$SCRIPT_DIR/config/niri"
SRC_NOCTALIA="$SCRIPT_DIR/config/noctalia"
SRC_SETTINGS="$SCRIPT_DIR/local/state/noctalia/settings.toml"
SRC_CLIPBOARD="$SCRIPT_DIR/local/bin/niri-universal-clipboard"
SRC_PLUGINS="$SCRIPT_DIR/local/state/noctalia/plugins/materialized/community"

DEST_NIRI="$CONFIG_HOME/niri"
DEST_NOCTALIA="$CONFIG_HOME/noctalia"
DEST_SETTINGS="$STATE_HOME/noctalia/settings.toml"
DEST_CLIPBOARD="$BIN_HOME/niri-universal-clipboard"
DEST_PLUGINS="$STATE_HOME/noctalia/plugins/materialized/community"

dry_run=false
force=false
reload=true
list_only=false
components=()
changed_files=0

usage() {
  cat <<EOF
Usage: ${0##*/} [component ...] [options]

Components:
  --niri          Niri compositor config
  --noctalia      Noctalia config + active settings
  --clipboard     Universal clipboard helper
  --plugins       Enabled community Noctalia plugins
  --all, -a       Install every component
  --list          Show components and destinations

Options:
  --dry-run, -n   Show what would change, write nothing
  --force, -f     Overwrite without making backups
  --no-reload     Do not ask running niri/Noctalia to reload
  -h, --help      Show this help

With no component flags, an interactive picker is shown.
EOF
}

component_paths() {
  case "$1" in
    niri) printf '%s\n' "$DEST_NIRI" ;;
    noctalia) printf '%s\n' "$DEST_NOCTALIA and $DEST_SETTINGS" ;;
    clipboard) printf '%s\n' "$DEST_CLIPBOARD" ;;
    plugins) printf '%s\n' "$DEST_PLUGINS" ;;
    *) return 1 ;;
  esac
}

validate_component() {
  case "$1" in
    niri | noctalia | clipboard | plugins) return 0 ;;
    *)
      printf 'error: unknown component "%s"\n' "$1" >&2
      return 1
      ;;
  esac
}

add_component() {
  validate_component "$1" || exit 1
  local existing
  for existing in "${components[@]:-}"; do
    [[ $existing == "$1" ]] && return 0
  done
  components+=("$1")
}

show_list() {
  printf 'Niri/Noctalia components\n\n'
  printf '  niri       %s\n' "$(component_paths niri)"
  printf '  noctalia   %s\n' "$(component_paths noctalia)"
  printf '  clipboard  %s\n' "$(component_paths clipboard)"
  printf '  plugins    %s\n' "$(component_paths plugins)"
  printf '\nPaths honor XDG_CONFIG_HOME and XDG_STATE_HOME. The clipboard helper always installs to $HOME/.local/bin to match niri keybinds.\n'
}

choose_interactively() {
  if [[ ! -t 0 ]]; then
    printf 'error: no components selected (use --all or pass component flags)\n' >&2
    exit 1
  fi

  printf 'Niri + Noctalia installer\n\n'
  printf '  1) Niri compositor       %s\n' "$DEST_NIRI"
  printf '  2) Noctalia shell        %s\n' "$DEST_NOCTALIA"
  printf '                           %s\n' "$DEST_SETTINGS"
  printf '  3) Universal clipboard   %s\n' "$DEST_CLIPBOARD"
  printf '  4) Noctalia plugins      %s\n' "$DEST_PLUGINS"
  printf '\nEnter numbers separated by spaces, or "all" [default: all]: '

  local selection
  read -r selection || {
    printf '\nAborted.\n'
    exit 1
  }
  selection=${selection:-all}

  if [[ $selection == all || $selection == a ]]; then
    add_component niri
    add_component noctalia
    add_component clipboard
    add_component plugins
    return
  fi

  local token
  for token in $selection; do
    case "$token" in
      1) add_component niri ;;
      2) add_component noctalia ;;
      3) add_component clipboard ;;
      4) add_component plugins ;;
      *)
        printf 'error: invalid selection "%s" (expected 1-4 or all)\n' "$token" >&2
        exit 1
        ;;
    esac
  done
}

backup_path() {
  local path="$1" base backup n

  if $force || [[ ! -e $path ]]; then
    return 0
  fi

  if [[ -d $path ]]; then
    base="${path%/}.backup-$(date +%Y%m%d-%H%M%S)"
  else
    base="${path}.bak.$(date +%Y%m%d-%H%M%S)"
  fi
  backup="$base"
  n=1
  while [[ -e $backup ]]; do
    backup="$base-$n"
    n=$((n + 1))
  done

  cp -a -- "$path" "$backup"
  printf '  backup   %s\n' "$backup"
}

# Compare every file in a source tree against its destination counterpart.
# Extra files in the destination are intentionally left alone.
install_tree() {
  local src="$1" dest="$2" rel file component_changed=0
  local -a files=()

  mapfile -d '' files < <(find "$src" -type f -print0 | sort -z)

  for file in "${files[@]}"; do
    rel="${file#"$src"/}"
    if [[ -f "$dest/$rel" ]] && cmp -s -- "$file" "$dest/$rel"; then
      printf '  same     %s\n' "$dest/$rel"
    else
      printf '  %-8s %s\n' "$([[ -e "$dest/$rel" ]] && echo update || echo install)" "$dest/$rel"
      component_changed=$((component_changed + 1))
    fi
  done

  if [[ $component_changed -eq 0 ]]; then
    printf '  no changes\n'
    return 0
  fi

  if $dry_run; then
    changed_files=$((changed_files + component_changed))
    return 0
  fi

  backup_path "$dest"
  mkdir -p -- "$dest"
  cp -a -- "$src"/. "$dest"/
  changed_files=$((changed_files + component_changed))
}

install_file() {
  local src="$1" dest="$2" mode="$3" current_mode=""

  [[ -f $src ]] || {
    printf 'error: missing source file: %s\n' "$src" >&2
    exit 1
  }

  if [[ -f $dest ]]; then
    current_mode="$(stat -c '%a' "$dest")"
    if cmp -s -- "$src" "$dest" && [[ $current_mode == "${mode#0}" ]]; then
      printf '  same     %s\n' "$dest"
      return 0
    fi
  fi

  printf '  %-8s %s\n' "$([[ -e "$dest" ]] && echo update || echo install)" "$dest"

  if $dry_run; then
    changed_files=$((changed_files + 1))
    return 0
  fi

  backup_path "$dest"
  mkdir -p -- "$(dirname -- "$dest")"
  install -m "$mode" -- "$src" "$dest"
  changed_files=$((changed_files + 1))
}

install_niri() {
  printf '\nNiri compositor\n'
  install_tree "$SRC_NIRI" "$DEST_NIRI"
}

install_noctalia() {
  printf '\nNoctalia shell\n'
  install_tree "$SRC_NOCTALIA" "$DEST_NOCTALIA"
  install_file "$SRC_SETTINGS" "$DEST_SETTINGS" 644
}

install_clipboard() {
  printf '\nUniversal clipboard helper\n'
  install_file "$SRC_CLIPBOARD" "$DEST_CLIPBOARD" 755
}

install_plugins() {
  printf '\nNoctalia community plugins\n'
  install_tree "$SRC_PLUGINS" "$DEST_PLUGINS"
}

reload_services() {
  local component
  local need_niri=false
  local need_noctalia=false

  for component in "${components[@]}"; do
    case "$component" in
      niri) need_niri=true ;;
      noctalia | plugins) need_noctalia=true ;;
    esac
  done

  if $need_niri && command -v niri >/dev/null 2>&1; then
    if niri msg version >/dev/null 2>&1; then
      if niri msg action load-config-file >/dev/null 2>&1; then
        printf 'Reloaded niri config.\n'
      else
        printf 'niri is running, but reload failed; restart niri to apply.\n'
      fi
    fi
  fi

  if $need_noctalia && command -v noctalia >/dev/null 2>&1; then
    if noctalia msg config-reload >/dev/null 2>&1; then
      printf 'Reloaded Noctalia config.\n'
    fi
  fi
}

check_dependencies() {
  local component missing=()
  local need_wtype=false
  local need_jq=false

  command -v niri >/dev/null 2>&1 || missing+=(niri)
  command -v noctalia >/dev/null 2>&1 || missing+=(noctalia)

  for component in "${components[@]}"; do
    [[ $component == clipboard ]] && need_wtype=true && need_jq=true
  done

  if $need_wtype && ! command -v wtype >/dev/null 2>&1; then
    missing+=(wtype)
  fi
  if $need_jq && ! command -v jq >/dev/null 2>&1; then
    missing+=(jq)
  fi

  if ((${#missing[@]})); then
    printf '\nMissing dependencies: %s\n' "${missing[*]}"
    printf 'On CachyOS/Arch: sudo pacman -S --needed %s\n' "${missing[*]}"
  fi
}

while (($# > 0)); do
  case "$1" in
    --all | -a)
      add_component niri
      add_component noctalia
      add_component clipboard
      add_component plugins
      ;;
    --niri) add_component niri ;;
    --noctalia) add_component noctalia ;;
    --clipboard) add_component clipboard ;;
    --plugins) add_component plugins ;;
    --dry-run | -n) dry_run=true ;;
    --force | -f) force=true ;;
    --no-reload) reload=false ;;
    --list) list_only=true ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      printf 'error: unknown option "%s"\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if $list_only; then
  show_list
  exit 0
fi

((${#components[@]} > 0)) || choose_interactively

for component in "${components[@]}"; do
  case "$component" in
    niri) install_niri ;;
    noctalia) install_noctalia ;;
    clipboard) install_clipboard ;;
    plugins) install_plugins ;;
  esac
done

printf '\n'
if $dry_run; then
  printf 'Dry run — %d file(s) would change. Nothing was written.\n' "$changed_files"
  exit 0
fi

if [[ $changed_files -eq 0 ]]; then
  printf 'Already up to date.\n'
else
  printf 'Installed %d file(s).\n' "$changed_files"
fi

printf '\nNote: display.kdl and Noctalia settings.toml contain this machine'"'"'s\n'
printf 'monitor names and wallpaper paths. Adjust them after installing on\n'
printf 'different hardware.\n'

if $reload; then
  reload_services
fi

check_dependencies
