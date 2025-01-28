{ lib, config, ... }:
let
  cfg = config.profile.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.file.".config/wallust/templates/alacritty.toml".text =
      # toml
      ''
        [window]
        opacity = {{alpha/100}}

        [colors]
        [colors.primary]
        background = "{{background}}"
        foreground = "{{foreground}}"

        [colors.cursor]
        text = "CellForeground"
        cursor = "{{cursor}}"

        [colors.bright]
        black =   "{{color0}}"
        red =     "{{color1}}"
        green =   "{{color2}}"
        yellow =  "{{color3}}"
        blue =    "{{color4}}"
        magenta = "{{color5}}"
        cyan =    "{{color6}}"
        white =   "{{color7}}"

        [colors.normal]
        black =   "{{color8}}"
        red =     "{{color9}}"
        green =   "{{color10}}"
        yellow =  "{{color11}}"
        blue =    "{{color12}}"
        magenta = "{{color13}}"
        cyan =    "{{color14}}"
        white =   "{{color15}}"
      '';

    profile.hyprland.wallust.settings.templates.alacritty =
      let
        out = config.home.homeDirectory + "/.cache/wallust";
      in
      {
        template = "alacritty.toml";
        target = "${out}/alacritty.toml";
      };

    programs.alacritty = {
      enable = true;
      settings = {
        import = [ "${config.home.homeDirectory}/.cache/wallust/alacritty.toml" ];
        live_config_reload = true;
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Italic";
          };
          bold = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold";
          };
          bold_italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold Italic";
          };
          size = 11.0;
        };
      };
    };
  };
}
