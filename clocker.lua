local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")

function clockerInfo(textwidget, timeout)
  local timer = timer({timeout = timeout})

  function update()
    out = awful.util.pread("clocker status")
    textwidget:set_text(out)
  end

  timer:connect_signal("timeout", update)
  timer:start()
  update()
end
