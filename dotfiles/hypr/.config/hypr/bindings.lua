-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Application bindings
o.bind("SUPER + SHIFT + Z", "Zed", "/home/dinatih/.local/bin/zed")

-- If your web app url contains #, type it as ## to prevent hyprland treating it as a comment
hl.unbind("SUPER + SHIFT + A")
o.bind("SUPER + SHIFT + A", "Gemini", 'omarchy-launch-webapp "https://gemini.google.com/app"')

hl.unbind("SUPER + SHIFT + ALT + A")
o.bind("SUPER + SHIFT + ALT + A", "Claude", 'omarchy-launch-webapp "https://claude.ai/new"')

hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Calendar", 'omarchy-launch-webapp "https://calendar.google.com/calendar/u/0/r/month?pli=1"')

hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Email", 'omarchy-launch-webapp "https://gmail.com"')

hl.unbind("SUPER + SHIFT + K")
o.bind("SUPER + SHIFT + K", "Google Keep", 'omarchy-launch-webapp "https://keep.google.com"')

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
