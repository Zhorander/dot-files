-------------------------------------------------
-- Brightness Widget for Awesome Window Manager
-- Shows the brightness level of the laptop display
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/brightness-widget

-- @author Pavel Makhov
-- @copyright 2017 Pavel Makhov
-------------------------------------------------

local wibox = require("wibox")
local watch = require("awful.widget.watch")
local gears = require('gears')
local awful = require('awful')

local brightness_cmd = "light -G"
local path_to_icons = "/usr/share/icons/Arc/status/symbolic/"

local get_brightness = function()
    local f = io.popen(brightness_cmd)
    local t = f:read('*a')
    f:close()
    return t
end

local brightness_widget = wibox.widget {
    -- {
    --     id = 'brightness',
    --     image = path_to_icons .. "display-brightness-symbolic.svg",
    --     resize = false,
    --     widget = wibox.widget.imagebox,
    -- },
    {
        id = 'progress',
        max_value = 1,
        forced_width = 50,
        border_width = 0.5,
        color = '#008080',
        background_color = '#3a3a3a',
        shape = gears.shape.rounded_bar,
        clip = true,
        margins = {
            top = 5,
            bottom = 5
        },
        widget = wibox.widget.progressbar
    },
    top = 1,
    widget = wibox.container.margin,
    layout = wibox.layout.fixed.horizontal
}

local update = function(widget)
    local bl = tonumber(get_brightness())

    widget.progress:set_value(bl / 100)
end

brightness_widget:connect_signal("button::press", function(_,_,_,button)
    if (button == 4)     then awful.spawn("light -A 5", false) --increase backlight by 5
    elseif (button == 5) then awful.spawn("light -U 5", false) --decrease backlight by 5
    end
    update(brightness_widget)
end)

watch(
brightness_cmd, 2,
function(widget, stdout, stderr, exitreason, exitcode)
    update(widget)
end,
brightness_widget
)

return brightness_widget
