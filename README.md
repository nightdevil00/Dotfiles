# Dotfiles

Personal Linux configuration, one program per subdirectory.

## What's here

| Config | What it is |
| --- | --- |
| [Hyprland](Hyprland/) | Hyprland configuration and keybindings, written in Lua |

## Installing

```sh
git clone https://github.com/nightdevil00/Dotfiles.git
cd Dotfiles
./install.sh
```

`install.sh` copies the files into `~/.config/hypr`. It backs up whatever is
already there to a timestamped directory first, so it is safe to run on a
machine you have already configured:

```sh
./install.sh --dry-run    # show what would change, write nothing
./install.sh --force      # skip the backup
```

Re-running is safe — identical files are reported as unchanged and skipped.

Then apply the config without logging out:

```sh
hyprctl reload
```

## Hyprland

| File | Purpose |
| --- | --- |
| `hyprland.lua` | Entry point; loads the rest and decides what to source from where |
| `bindings.lua`, `bindings/` | Keybindings, split by area — applications, clipboard, media, tiling, utilities, voxtype |
| `monitors.lua` | Monitor, mode, scale, position and transform |
| `windows.lua` | Window rules and per-app behaviour |
| `input.lua` | Keyboard, touchpad, mouse and stylus settings |
| `looknfeel.lua` | Cursor, focus, border and misc feel |
| `animations.lua` | Window and workspace animations |
| `nvidia.lua` | NVIDIA-specific settings |
| `settings.lua` | Miscellaneous settings |
| `xdph.conf`, `hyprsunset.conf` | XWayland and blue-light / night light configuration |

The config is written against [hyprland-lua](https://github.com/hyprwm/hyprland-lua)
and layers over an [Omarchy](https://omarchy.org/) base install.
