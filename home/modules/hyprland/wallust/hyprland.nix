{ config, lib, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.file.".config/wallust/templates/hyprland.conf".text =
      # hyprlang
      ''
        $background = rgb({{background | strip}})
        $foreground = rgb({{foreground | strip}})
        $color0 = rgb({{color0 | strip}})
        $color1 = rgb({{color1 | strip}})
        $color2 = rgb({{color2 | strip}})
        $color3 = rgb({{color3 | strip}})
        $color4 = rgb({{color4 | strip}})
        $color5 = rgb({{color5 | strip}})
        $color6 = rgb({{color6 | strip}})
        $color7 = rgb({{color7 | strip}})
        $color8 = rgb({{color8 | strip}})
        $color9 = rgb({{color9 | strip}})
        $color10 = rgb({{color10 | strip}})
        $color11 = rgb({{color11 | strip}})
        $color12 = rgb({{color12 | strip}})
        $color13 = rgb({{color13 | strip}})
        $color14 = rgb({{color14 | strip}})
        $color15 = rgb({{color15 | strip}})

        general {
            col.inactive_border = $color11
        }

        decoration {
            inactive_opacity = {{alpha / 100}}
        }
      '';

    profile.hyprland.wallust.settings.templates.hyprland =
      let
        out = config.home.homeDirectory + "/.cache/wallust";
      in
      {
        template = "hyprland.conf";
        target = out + "/hyprland.conf";
      };
  };
}
