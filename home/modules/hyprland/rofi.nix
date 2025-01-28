{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profile.hyprland;
  inherit (lib.meta) getExe;
  selectWindowScript =
    pkgs.writeShellScriptBin ''select-window.sh'' # sh
      ''
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
                hyprctl --batch "dispatch focuswindow address:''${fullscreen_on_same_ws}; dispatch fullscreen 1;"
            fi
        fi
      '';
  openProjectScript =
    pkgs.writeShellScriptBin ''select-project.sh'' # sh
      ''
        dir=$(zoxide query --list | rofi -dmenu -i -matching fuzzy)
        if [[ "$dir" != "" ]]; then
            foot --title="Project: $dir" --working-directory="$dir"
        fi
      '';
in
{
  config = lib.mkIf false {
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
      "$mod, P, exec, ${getExe openProjectScript}"
    ];

    home.file.".config/wallust/templates/rofi.rasi".text =
      # css
      ''
        * {
            background: rgba(0,0,1,0.5);
            foreground: #FFFFFF;
            color0:     {{color0}};
            color1:     {{color1}};
            color2:     {{color2}};
            color3:     {{color3}};
            color4:     {{color4}};
            color5:     {{color5}};
            color6:     {{color6}};
            color7:     {{color7}};
            color8:     {{color8}};
            color9:     {{color9}};
            color10:    {{color10}};
            color11:    {{color11}};
            color12:    {{color12}};
            color13:    {{color13}};
            color14:    {{color14}};
            color15:    {{color15}};
            border-width: 3px;
            current-image: url("${config.home.homeDirectory}/.cache/wallpaper/blurred.png", height);
        }
      '';

    profile.hyprland.wallust.settings.templates.rofi =
      let
        out = config.home.homeDirectory + "/.cache/wallust";
      in
      {
        template = "rofi.rasi";
        target = "${out}/rofi.rasi";
      };
  };
}
