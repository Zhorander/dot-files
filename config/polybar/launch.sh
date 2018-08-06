#!/usr/bin/env sh

#\033[1;37mxset +fp /home/elias/.fonts\033[0m
#\033[1;37mxset fp rehash\033[0m

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch bar1 and bar2
# polybar hdmi &
polybar topbar &

echo "Bars launched..."
