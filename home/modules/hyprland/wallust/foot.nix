{ config, lib, ... }:
let
  cfg = config.profile.hyprland;
  inherit (lib.generators) toINI;
in
{
  config = lib.mkIf cfg.enable {
    home.file.".config/wallust/templates/foot.ini".text = (toINI { }) {
      colors = {
        alpha = "{{ alpha/100 }}";
        background = "{{ background | strip }}";
        foreground = "{{ foreground | strip }}";
        flash = "{{ color2 | strip }}";
        flash-alpha = "0.5";
        regular0 = "{{ color0 | strip }}";
        regular1 = "{{ color1 | strip }}";
        regular2 = "{{ color2 | strip }}";
        regular3 = "{{ color3 | strip }}";
        regular4 = "{{ color4 | strip }}";
        regular5 = "{{ color5 | strip }}";
        regular6 = "{{ color6 | strip }}";
        regular7 = "{{ color7 | strip }}";
        bright0 = "{{ color8 | strip }}";
        bright1 = "{{ color9 | strip }}";
        bright2 = "{{ color10 | strip }}";
        bright3 = "{{ color11 | strip }}";
        bright4 = "{{ color12 | strip }}";
        bright5 = "{{ color13 | strip }}";
        bright6 = "{{ color14 | strip }}";
        bright7 = "{{ color15 | strip }}";
      };
    };

    profile.hyprland.wallust.settings.templates.foot =
      let
        out = config.home.homeDirectory + "/.cache/wallust";
      in
      {
        template = "foot.ini";
        target = out + "/foot.ini";
      };
  };
}