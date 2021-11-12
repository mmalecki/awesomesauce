-- Based on https://github.com/koentje/awesome-batteryInfo.
--
-- This function returns a formatted string with the current battery status. It
-- can be used to populate a text widget in the awesome window manager. Based
-- on the "Gigamo Battery Widget" found in the wiki at awesome.naquadah.org

local naughty = require("naughty")
local beautiful = require("beautiful")

function batteryInfo(adapter, textwidget, timeout)
  local batterywidget_timer = timer({timeout = timeout})

  function update()
    local battery, icon, percent
    local color = "white"
    local base = "/sys/class/power_supply/"..adapter
    local fh = io.open(base.."/present", "r")

    if fh == nil then
      battery = "A/C"
      icon = ""
      percent = ""
    else
      local fcur = io.open(base.."/energy_now") or io.open(base.."/charge_now")
      local fcap = io.open(base.."/energy_full") or io.open(base.."/charge_full")
      local fsta = io.open(base.."/status")
      local cur = fcur:read()
      local cap = fcap:read()
      local sta = fsta:read()
      fcur:close()
      fcap:close()
      fsta:close()

      if cap == nil then
        textwidget:set_markup("<span color='red'>?</span>")
        return
      end

      battery = math.floor(cur * 100 / cap)
    
      if sta:match("Charging") then
        icon = "⚡"
        percent = "%"
        color = "green"
      elseif sta:match("Discharging") then
        icon = ""
        percent = "%"

        if tonumber(battery) < 15 then
          color = "red"
        end
      else -- This matches "Uknown" state too
        icon = ""
        percent = "%"
      end
    end

    fh:close()
    textwidget:set_markup("<span color='"..color.."'>"..icon..battery..percent.."</span>")
  end

  batterywidget_timer:connect_signal("timeout", update)
  batterywidget_timer:start()
  update()
end
