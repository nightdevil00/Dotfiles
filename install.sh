#!/usr/bin/env bash
# Install this Hyprland configuration into ~/.config/hypr
#
#   ./install.sh              back up the current config, then install
#   ./install.sh --dry-run    show what would change, touch nothing
#   ./install.sh --force      install without backing up first
#
# Your existing ~/.config/hypr is copied to a timestamped backup before
# anything is overwritten, so this is safe to run on a machine you already
# have configured.

set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/Hyprland"
DEST="$HOME/.config/hypr"

dry_run=false
force=false
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) dry_run=true ;;
    --force|-f)   force=true ;;
    -h|--help)    sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)            echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

[[ -d $SRC ]] || { echo "error: $SRC not found" >&2; exit 1; }

files=$(cd "$SRC" && find . -type f | sed 's|^\./||' | sort)
count=$(printf '%s\n' "$files" | grep -c . || true)

echo "Source: $SRC"
echo "Target: $DEST"
echo "Files:  $count"
echo

changed=0
while IFS= read -r f; do
  [[ -n $f ]] || continue
  if [[ -f "$DEST/$f" ]] && cmp -s "$SRC/$f" "$DEST/$f"; then
    printf '  same     %s\n' "$f"
  else
    printf '  %-7s %s\n' "$([ -f "$DEST/$f" ] && echo update || echo install)" "$f"
    changed=$((changed + 1))
  fi
done <<< "$files"

if [[ -d $DEST ]] && [[ $changed -gt 0 ]] && ! $dry_run && ! $force; then
  backup="$HOME/.config/hypr.backup-$(date +%Y%m%d-%H%M%S)"
  echo
  echo "Backing up current config to $backup"
  cp -a "$DEST" "$backup"
  echo "  (restore with: cp -a '$backup' '$DEST')"
fi

if $dry_run; then
  echo
  echo "Dry run — $changed file(s) would change. Nothing was written."
  exit 0
fi

if [[ $changed -eq 0 ]]; then
  echo
  echo "Already up to date."
  exit 0
fi

mkdir -p "$DEST"
while IFS= read -r f; do
  [[ -n $f ]] || continue
  mkdir -p "$DEST/$(dirname "$f")"
  cp "$SRC/$f" "$DEST/$f"
done <<< "$files"

echo "Installed $changed file(s) into $DEST"
echo
if command -v hyprctl >/dev/null; then
  echo "Apply them with:  hyprctl reload"
else
  echo "hyprctl not found on PATH. Log out and back in to pick up the config."
fi
