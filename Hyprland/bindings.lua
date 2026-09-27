-- Keybindings.
--
-- ~/.config/hypr/bindings/ holds a vendored copy of Omarchy's default
-- bindings (was /usr/share/omarchy/default/hypr/bindings). The
-- omarchy_default_bindings = false flag in hyprland.lua stops the packaged
-- originals from loading, so these files are the only source of Omarchy's
-- bindings and your edits here stick.
--
-- Loaded in sorted order: applications, clipboard, media, tiling, utilities,
-- voxtype. Personal bindings below come last, so they win any conflict.

local paths = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")

require_all.files(paths.config_home .. "/hypr/bindings", "hypr.bindings")

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Personal bindings. Everything above this line came from Omarchy; everything
-- below is yours.

-- Logitech MX Keys: the Print key is remapped to the screenshot shortcut.
-- Unbind first because bindings/applications.lua binds this to Google Photos.
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")

-- Dictation and emoji panel.
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Keypad keys, which the MX Keys lacks.
o.bind("SUPER +  XF86SelectiveScreenshot", nil, "omarchy-capture-screenshot")
o.bind("SUPER +  XF86Favorites ", nil, "omarchy-capture-screenrecording")
