# Niri + Noctalia

Niri compositor configuration, Noctalia shell settings, the enabled Noctalia
plugins, and the Omarchy-style universal clipboard helper from this machine.

## What is included

| Source | Installed to | Purpose |
| --- | --- | --- |
| `config/niri/` | `~/.config/niri/` | `config.kdl`, split `cfg/*.kdl`, and the Noctalia-generated `noctalia.kdl` |
| `config/noctalia/config.toml` | `~/.config/noctalia/config.toml` | Noctalia boot configuration (polkit agent) |
| `local/state/noctalia/settings.toml` | `~/.local/state/noctalia/settings.toml` | Active Noctalia settings: bar, theme, wallpaper, plugins, clipboard |
| `local/bin/niri-universal-clipboard` | `~/.local/bin/niri-universal-clipboard` | `Super+A/C/X/V` clipboard helper used by `cfg/keybinds.kdl` |
| `local/bin/noctalia-theme-sync-chrome` | `~/.local/bin/noctalia-theme-sync-chrome` | Syncs the Noctalia shell accent color to Chromium/Chrome/Edge/Brave via enterprise policy |
| `local/state/noctalia/plugins/materialized/community/` | `~/.local/state/noctalia/plugins/materialized/community/` | DropWall, Niri Animations, and Spotify Media plugins |
| `config/systemd/user/noctalia-chrome-sync.{path,service}` | `~/.config/systemd/user/` | Auto-sync Noctalia accent color to Chromium-based browsers |

The installer honors `XDG_CONFIG_HOME` and `XDG_STATE_HOME`. The clipboard
helper always installs to `~/.local/bin` because the niri keybinds reference
`$HOME/.local/bin/niri-universal-clipboard`.

### Deliberately not included

These are private or regenerated automatically, so they stay out of the repo:

- `~/.local/state/noctalia/clipboard/` and notification history
- `~/.local/state/noctalia/recently_used.json` and `usage_counts.json`
- `~/.local/state/noctalia/community-palettes/` and `community-templates/` caches
- `~/.local/state/noctalia/state.toml` (machine-local migration/template state)
- Noctalia plugin sources and thumbnail caches
- Wallpaper images under `~/Pictures/`

## Install

From this directory:

```sh
./install.sh                 # interactive component picker
./install.sh --all           # everything
./install.sh --niri          # compositor only
./install.sh --noctalia      # Noctalia config + settings
./install.sh --clipboard     # universal clipboard helper
./install.sh --plugins       # the three enabled Noctalia plugins
```

Useful options:

```sh
./install.sh --all --dry-run   # show what would change
./install.sh --all --force     # skip backups
./install.sh --all --no-reload # do not reload running niri/Noctalia
./install.sh --list            # show paths
```

Or install from the repository root:

```sh
cd ..
./install.sh niri
```

Every existing destination is copied to a timestamped backup before being
replaced. Identical files are reported as `same` and skipped.

## Requirements

```sh
sudo pacman -S --needed niri noctalia wtype jq
```

- `wtype` and `jq` are needed by `niri-universal-clipboard`.
- `Noctalia` is started by `spawn-at-startup "noctalia"` in
  `config/niri/cfg/autostart.kdl`.
- The plugins also need their own runtime dependencies; DropWall requires
  `python-gobject`, `gtk3`, and `gtk-layer-shell`.
- The plugin files here are Noctalia's materialized copies, not the plugin
  source repositories. Noctalia can update or reinstall them from its plugin
  settings if needed.

### Chrome/Chromium theme sync

The sync helper writes `BrowserThemeColor` to `/etc/{chromium,opt/chrome,opt/edge,brave}/policies/managed/color.json`
and needs passwordless sudo for those paths. Install the sudoers rule (once, as root):

```sh
sudo tee /etc/sudoers.d/noctalia-chrome-theme >/dev/null <<'SUDOERS'
%mihai ALL=(root) NOPASSWD: /usr/bin/tee /etc/chromium/policies/managed/color.json
%mihai ALL=(root) NOPASSWD: /usr/bin/tee /etc/opt/chrome/policies/managed/color.json
%mihai ALL=(root) NOPASSWD: /usr/bin/tee /etc/opt/edge/policies/managed/color.json
%mihai ALL=(root) NOPASSWD: /usr/bin/tee /etc/brave/policies/managed/color.json
%mihai ALL=(root) NOPASSWD: /usr/bin/mkdir -p /etc/chromium/policies/managed
%mihai ALL=(root) NOPASSWD: /usr/bin/mkdir -p /etc/opt/chrome/policies/managed
%mihai ALL=(root) NOPASSWD: /usr/bin/mkdir -p /etc/opt/edge/policies/managed
%mihai ALL=(root) NOPASSWD: /usr/bin/mkdir -p /etc/brave/policies/managed
%mihai ALL=(root) NOPASSWD: /usr/bin/chown root\:root *
%mihai ALL=(root) NOPASSWD: /usr/bin/chmod 644 *
SUDOERS
```

Adjust `%mihai` to your username. The systemd path unit is enabled automatically
by the installer; it watches Noctalia settings and re-syncs on wallpaper/theme changes.

## Universal clipboard

`config/niri/cfg/keybinds.kdl` maps:

| Key | Action |
| --- | --- |
| `Super+A` | Select all (`Ctrl+A`) |
| `Super+C` | Copy (`Ctrl+C`, or `Ctrl+Shift+C` in terminals) |
| `Super+X` | Cut (`Ctrl+X`) |
| `Super+V` | Paste (`Ctrl+V`, or `Ctrl+Shift+V` in terminals) |
| `Super+Ctrl+V` | Noctalia clipboard history |

The helper reads the focused app from `niri msg --json focused-window` and uses
`wtype` to inject the correct chord. Noctalia stores the history and auto-pastes
the selected entry.

Because `Super+C` is now copy, the previous `center-column` binding moved to
`Super+Shift+C`.

## Machine-specific values

`config/niri/cfg/display.kdl` and `local/state/noctalia/settings.toml` contain
this laptop's monitor names (`eDP-1`, `HDMI-A-4`) and wallpaper paths under
`/home/mihai/Pictures/Wallpapers`. Adjust them after installing on different
hardware, or Noctalia/niri may fall back to defaults.
