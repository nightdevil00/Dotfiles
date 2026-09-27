-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Omarchy's default bindings are now vendored into ~/.config/hypr/bindings/,
-- which hypr/bindings.lua loads in their place. Keep this flag set so the
-- packaged defaults are not loaded a second time and fight over the same keys.
--
-- This copy no longer receives upstream fixes: re-sync it with
--   diff -ru /usr/share/omarchy/default/hypr/bindings ~/.config/hypr/bindings
-- after an `omarchy update`.
omarchy_default_bindings = false
--
-- To go back to Omarchy's maintained defaults instead, comment the line above
-- and delete ~/.config/hypr/bindings/.
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.windows")
require("hypr.nvidia")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Use the iGPU's VA-API driver, not NVIDIA's. Hyprland composites on the
-- integrated GPU, so pointing libva at NVDEC here breaks video in browsers.
-- NVD_BACKEND=egl matches that: the direct NVDEC backend wants the NVIDIA EGL
-- stack this session is deliberately not using.
hl.env("LIBVA_DRIVER_NAME", "iHD")
hl.env("NVD_BACKEND", "egl")

-- omarchy-settings:load
require("hypr.settings")
