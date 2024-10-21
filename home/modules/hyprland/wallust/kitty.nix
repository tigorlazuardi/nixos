{ config, lib, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf (cfg.enable && config.programs.kitty.enable) {
    home.file.".config/wallust/templates/kitty.conf".text =
      # css
      ''
        foreground         {{foreground}}
        background         {{background}}
        background_opacity {{ alpha / 100 }}
        cursor             {{cursor}}

        active_tab_foreground     {{background}}
        active_tab_background     {{foreground}}
        inactive_tab_foreground   {{foreground}}
        inactive_tab_background   {{background}}

        active_border_color   {{foreground}}
        inactive_border_color {{background}}
        bell_border_color     {{color1}}

        color0       {{color0}}
        color1       {{color1}}
        color2       {{color2}}
        color3       {{color3}}
        color4       {{color4}}
        color5       {{color5}}
        color6       {{color6}}
        color7       {{color7}}
        color8       {{color8}}
        color9       {{color9}}
        color10      {{color10}}
        color11      {{color11}}
        color12      {{color12}}
        color13      {{color13}}
        color14      {{color14}}
        color15      {{color15}}
      '';

    profile.hyprland.wallust.settings.templates.kitty = {
      template = "kitty.conf";
      target = "${config.home.homeDirectory}/.config/kitty/kitty.d/99-colors.conf";
    };
  };
}