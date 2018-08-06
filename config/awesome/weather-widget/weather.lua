-------------------------------------------------
-- Weather Widget based on the OpenWeatherMap
-- https://openweathermap.org/
--
-- @author Pavel Makhov
-- @copyright 2018 Pavel Makhov
-------------------------------------------------

local http = require("socket.http")
local json = require("weather-widget.json")
local naughty = require("naughty")
local wibox = require("wibox")
local awful = require('awful')

local path_to_icons = "/usr/share/icons/Arc/status/symbolic/"

local weather_cmd = 'GET https://api.darksky.net/forecast/your_api_key/34.054673,-106.906169?units=us&exclude=minutely,hourly,daily,alerts,flags'

local icon_widget = wibox.widget {
    {
        id = "icon",
        resize = false,
        widget = wibox.widget.imagebox,
    },
    layout = wibox.container.margin(brightness_icon, 0, 0, 0),
    set_image = function(self, path)
        self.icon.image = path
    end,
}

local temp_widget = wibox.widget{
    text = 'connecting...',
    widget = wibox.widget.textbox
}

local weather_widget = wibox.widget {
    icon_widget,
    temp_widget,
    layout = wibox.layout.fixed.horizontal,
}

-- helps to map openWeatherMap icons to Arc icons
local icon_map = {
    ["clear-day"] = "weather-clear-symbolic.svg",
    ["partly-cloudy-day"] = "weather-few-clouds-symbolic.svg",
    ["undef-1"] = "weather-clouds-symbolic.svg",
    ["cloudy"] = "weather-overcast-symbolic.svg",
    ["09d"] = "weather-showers-scattered-symbolic.svg",
    ["rain"] = "weather-showers-symbolic.svg",
    ["thunderstorm"] = "weather-storm-symbolic.svg",
    ["snow"] = "weather-snow-symbolic.svg",
    ["fog"] = "weather-fog-symbolic.svg",
    ["clear-night"] = "weather-clear-night-symbolic.svg",
    ["partly-cloudy-night"] = "weather-few-clouds-night-symbolic.svg",
    ["03n"] = "weather-clouds-night-symbolic.svg",
    ["04n"] = "weather-overcast-symbolic.svg",
    ["09n"] = "weather-showers-scattered-symbolic.svg",
    ["10n"] = "weather-showers-symbolic.svg",
    ["11n"] = "weather-storm-symbolic.svg",
    ["13n"] = "weather-snow-symbolic.svg",
    ["50n"] = "weather-fog-symbolic.svg",
    ["wind"] = "weather-windy.svg"
}

-- handy function to convert temperature from Kelvin to Celcius
function to_celcius(kelvin)
    return math.floor(tonumber(kelvin) - 273.15)
end

-- Return wind direction as a string.
function to_direction(degrees)
    -- Ref: https://www.campbellsci.eu/blog/convert-wind-directions
    if degrees == nil then
        return "Unknown dir"
    end
    local directions = {
        "N",
        "NNE",
        "NE",
        "ENE",
        "E",
        "ESE",
        "SE",
        "SSE",
        "S",
        "SSW",
        "SW",
        "WSW",
        "W",
        "WNW",
        "NW",
        "NNW",
        "N",
    }
    return directions[math.floor((degrees % 360) / 22.5) + 1]
end

local weather_timer = timer({ timeout = 60 })
local resp

local get_weather = function(stdout, stderr, exitreason, exitcode)
    resp = json.decode(stdout)
    icon_widget.image = path_to_icons .. icon_map[resp.currently.icon]
    temp_widget:set_text(string.format('%.0f', resp.currently.temperature) .. "°F")
end

weather_timer:connect_signal("timeout", function ()
   awful.spawn.easy_async(weather_cmd, get_weather)
end)
weather_timer:start()
weather_timer:emit_signal("timeout")

-- Notification with weather information. Popups when mouse hovers over the icon
local notification
weather_widget:connect_signal("mouse::enter", function()
    notification = naughty.notify{
        icon = path_to_icons .. icon_map[resp.currently.icon],
        icon_size=20,
        text =
            '<big>' .. resp.currently.summary .. '</big><br>' ..
            '<b>Humidity:</b> ' .. resp.currently.humidity .. '%<br>' ..
            '<b>Temperature: </b>' .. resp.currently.temperature .. '<br>' ..
            '<b>Pressure: </b>' .. resp.currently.pressure .. 'hPa<br>' ..
            '<b>Clouds: </b>' .. string.format('%.0f', resp.currently.cloudCover * 100) .. '%<br>' ..
            '<b>Wind: </b>' .. resp.currently.windSpeed .. 'm/s (' .. to_direction(resp.currently.windBearing) .. ')',
        timeout = 5, hover_timeout = 10,
        width = 200
    }
end)
weather_widget:connect_signal("mouse::leave", function()
    naughty.destroy(notification)
end)

return weather_widget
