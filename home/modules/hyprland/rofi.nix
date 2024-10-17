{ config, lib, pkgs, ... }:
let
  cfg = config.profile.hyprland;
  inherit (lib.meta) getExe;
  selectWindowScript = pkgs.writeShellScriptBin ''select-window.sh'' /*sh*/ ''
    state="$(hyprctl -j clients)"
    active_window="$(hyprctl -j activewindow)"

    current_addr="$(echo "$active_window" | gojq -r '.address')"

    window="$(echo "$state" |
        gojq -r '.[] | select(.monitor != -1 ) | "\(.address)    \(.workspace.name)    \(.title)"' |
        grep -v "scratch_term" |
        sed "s|$current_addr|focused ->|" |
        sort -r |
        rofi -dmenu -i -matching fuzzy)"

    addr="$(echo "$window" | awk '{print $1}')"
    ws="$(echo "$window" | awk '{print $2}')"

    if [[ "$addr" =~ focused* ]]; then
        echo 'already focused, exiting'
        exit 0
    fi

    fullscreen_on_same_ws="$(echo "$state" | gojq -r ".[] | select(.fullscreen == true) | select(.workspace.name == \"$ws\") | .address")"

    if [[ "$window" != "" ]]; then
        if [[ "$fullscreen_on_same_ws" == "" ]]; then
            hyprctl dispatch focuswindow address:''${addr}
        else
            notify-send 'Complex switch' "$window"
            hyprctl --batch "dispatch focuswindow address:''${fullscreen_on_same_ws}; dispatch fullscreen 1; dispatch focuswindow address:''${addr}; dispatch fullscreen 1"
        fi
    fi
  '';
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rofi-wayland
      gojq
    ];

    home.file.".config/rofi" = {
      source = ./rofi;
      recursive = true;
    };

    wayland.windowManager.hyprland.settings.bind = [
      "$mod, D, exec, rofi -show drun -replace -i"
      "$mod, F, exec, ${getExe selectWindowScript}"
    ];
  };
}
