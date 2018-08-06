function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

run compton -b --no-fading-openclose
run fluxgui
run nm-applet
xset r rate 180 25 #I like my key keyboard a little more sensitive
xinput --set-prop 11 290 0 #disable mousepad thing... can't remember
xinput --set-prop 11 280 1 #enable mousepad thing
