--spacer for widgets

local wibox = require('wibox')

function new(spacer, width)
    local sp = spacer or ''
    local w = width or 0

    local spacer = wibox.widget.textbox()
    spacer:set_text(sp)
    spacer.width = w
    return spacer
end

return new
