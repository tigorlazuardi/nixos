{ pkgs, ... }:
let
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  gojq = "${pkgs.gojq}/bin/gojq";
in
pkgs.writeShellScriptBin "focus-window.sh" # sh
  ''
    appname="$SWAYNC_APP_NAME"
    state="$(${hyprctl} -j clients)" 
    window="$(echo "$state" | ${gojq} -r --arg APP "$appname" '.[] | select(.class == $APP) | .address')"

    if [[ "$window" != "" ]]; then
        ${hyprctl} dispatch focuswindow address:"$window"
    fi
  ''
