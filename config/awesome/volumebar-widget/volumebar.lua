-------------------------------------------------
-- Volume Bar Widget for Awesome Window Manager
-- Shows the current volume level
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/volumebar-widget

-- @author Pavel Makhov
-- @copyright 2017 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local gears = require("gears")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")

local request_command = 'sh ~/.config/awesome/volumebar-widget/get_vol.sh'

function get_vol()
    local f = io.popen(request_command)
    local t = f:read('*a')
    f:close()
    return t
end

local bar_color = "#74aeab"
local mute_color = "#ff0000"
local background_color = "#3a3a3a"

local volumebar_widget = wibox.widget {
    {
        id = 'vol',
        max_value = 1,
        value = 0.33,
        forced_width = 50,
        paddings = 0,
        border_width = 0.5,
        color = bar_color,
        background_color = background_color,
        shape = gears.shape.rounded_bar,
        clip = true,
        margins = {
            top = 5,
            bottom = 5,
        },
        widget = wibox.widget.progressbar
    },
    -- {
    --     id = 'text',
    --     text = 'vol: ',
    --     widget = wibox.widget.textbox
    -- },
    layout = wibox.layout.stack
}

local update_graphic = function(widget, stdout, _, _, _)
    local volume = tonumber(get_vol())

    widget.vol:set_value(volume / 100.0)
    -- widget.text:set_text(volume / 100)
end

volumebar_widget:connect_signal("button::press", function(_,_,_,button)
    if (button == 4)     then awful.spawn("pactl set-sink-volume 0 +5%", false)
    elseif (button == 5) then awful.spawn("pactl set-sink-volume 0 -5%", false)
    elseif (button == 1) then awful.spawn("pactl set-sink-mute 0 toggle", false)
    end

    -- awful.spawn.easy_async(request_command, function(stdout, stderr, exitreason, exitcode)
    update_graphic(volumebar_widget)
    -- end)
end)

watch(request_command, 2, update_graphic, volumebar_widget)

return volumebar_widget
