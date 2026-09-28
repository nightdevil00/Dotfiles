# Fastfetch

Two [fastfetch](https://github.com/fastfetch-cli/fastfetch) configs, plus a small
installer that drops the one you pick into `~/.config/fastfetch/config.jsonc`.

Both configs use Nerd Font icons, so make sure your terminal font has them
(e.g. **JetBrainsMono Nerd Font**, **MesloLGS NF**, **Iosevka Term**).

## Screenshots

### config1 — minimal, boxed

![config1 screenshot](config1.png)

A single bordered column (drawn with `╭─╮ │ ╰─╯` keys) next to a small ASCII
logo. Every label gets its own colour, and the color palette is printed at the
bottom.

### config2 — sectioned

![config2 screenshot](config2.png)

Three framed sections — **Hardware**, **Software** and **Uptime / Age / DT** —
next to the builtin fastfetch logo. Each section uses a different key colour:
green, yellow, blue and magenta. It also prints how many days ago the system
was installed.

> config2 is based on [this config by u/aayush-le](https://www.reddit.com/r/GarudaLinux/comments/1dcq0dl/making_fastfetch_more_beautiful_linux/).

## Install

From a clone of this repo:

```sh
git clone https://github.com/nightdevil00/Dotfiles.git
cd Dotfiles/Fastfetch
./install.sh
```

```
fastfetch config installer

  1) config1 - minimal boxed modules, small ASCII logo
  2) config2 - Hardware / Software / Uptime sections, builtin logo

Choose a config [1-2]:
```

Or skip the menu and pass the number:

```sh
./install.sh 1
./install.sh 2
```

Then just run `fastfetch`.

### What the installer does

- creates `~/.config/fastfetch/` if it doesn't exist (honours `XDG_CONFIG_HOME`)
- copies the chosen file to `~/.config/fastfetch/config.jsonc`
- if a config is already there, backs it up first to
  `config.jsonc.bak.<timestamp>`

Re-running is safe — it just overwrites the config and keeps a backup.

### Uninstall

```sh
rm ~/.config/fastfetch/config.jsonc
```

## Files

| File | Description |
| --- | --- |
| `config1.jsonc` | Minimal boxed layout |
| `config2.jsonc` | Sectioned Hardware/Software/Uptime layout |
| `config1.png` | Screenshot of config1 |
| `config2.png` | Screenshot of config2 |
| `install.sh` | Installer |

## Requirements

- `fastfetch` — https://github.com/fastfetch-cli/fastfetch
  (Arch: `sudo pacman -S fastfetch`, Debian/Ubuntu: `sudo apt install fastfetch`,
  Fedora: `sudo dnf install fastfetch`)
- a **Nerd Font** for the icons
- `bash` for the installer

## Editing

The configs are plain JSONC, so you can tweak them and point fastfetch at your
own copy instead of the installed one:

```sh
fastfetch --config config1.jsonc
```

Handy things to change in `config1.jsonc`: the label width in the `╭───────────╮`
lines (it has to match the longest label), and the `{#31}`–`{#36}` colors.
In `config2.jsonc`: the `keyColor` of each section, and the `text` of the
`OS Age` command module.
