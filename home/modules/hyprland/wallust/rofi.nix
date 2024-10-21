{ config, lib, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf (cfg.enable && config.profile.kitty.enable) {
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
