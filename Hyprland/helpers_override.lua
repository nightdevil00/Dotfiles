-- Extend o.bind to support { menu = "..." } and { panel = "..." } table formats.
-- The vendored bindings in ~/.config/hypr/bindings/ use these formats, but the
-- packaged command_from() in /usr/share/omarchy/default/hypr/helpers.lua only
-- handles omarchy, launch, webapp, and tui keys.

local function command_from_extended(value, description)
  if type(value) ~= "table" then
    return value
  end

  if value.omarchy then
    return "omarchy-launch-" .. value.omarchy
  elseif value.focus and value.launch then
    return o.launch_sole(value.focus, value.launch)
  elseif value.launch then
    return o.launch(value.launch)
  elseif value.webapp then
    if value.focus then
      return o.launch_webapp_sole(description, value.webapp)
    else
      return o.launch_webapp(value.webapp)
    end
  elseif value.tui then
    if value.focus then
      return "omarchy-launch-or-focus-tui " .. o.shell_quote(value.tui)
    else
      return "omarchy-launch-tui " .. o.shell_quote(value.tui)
    end
  elseif value.menu then
    return "omarchy-menu toggle " .. o.shell_quote(value.menu)
  elseif value.panel then
    return "omarchy-shell shell toggle " .. o.shell_quote(value.panel)
  end

  return value
end

o.bind = function(keys, description, dispatcher, options)
  local opts = options or {}

  if description then
    opts.description = description
  end

  dispatcher = command_from_extended(dispatcher, description)

  if type(dispatcher) == "string" then
    dispatcher = hl.dsp.exec_cmd(dispatcher)
  end

  hl.bind(keys, dispatcher, opts)
end
